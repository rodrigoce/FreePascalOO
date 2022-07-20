unit mini_orm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, TypInfo, Generics.Collections,
  StrUtils;

type
  { Enum }

  TORMType = (ormTypeTimestamp, ormTypeTimestampNullIfZero, ormTypeInt32, ormTypeInt32NullIfZero,
    ormTypeString, ormTypeStringNullIfEmpty, ormTypeDecimal);

  {Forward Declarations}

  TORMField = class;

  {Types}

  TORMFieldList = specialize TList<TORMField>;

  {TORMEntity}

  TORMEntity = class
    private
      FEntityClassName: string;
      FClassOfEntity: TClass;
      FDBTableName: string;
      FFieldList: TORMFieldList;
      function GetCountPK: Integer;
    public
      constructor Create(AEntityClassName, ADBTableName: string; AClassOfEntity: TClass);
      //
      property EntityClassName: string read FEntityClassName;
      property ClassOfEntity: TClass read FClassOfEntity;
      property DBTableName: string read FDBTableName;
      property FieldList: TORMFieldList read FFieldList;
      property CountPK: Integer read GetCountPK;
      //
      function GetDBColumnNameOf(ClassPropName: string): string;
  end;

  {TORMField}

  TORMField = class
    private
      FDBColumnName: string;
      FEntityPropName: string;
      FDBType: string;
      FLength: Integer;
      FIsPK: Boolean;
      FHasSequence: Boolean;
      FORMType: TORMType;
      FPPropInfo: PPropInfo;
      function GetIsString: Boolean;
    public
      function GetIsOrNotNullValueOf(Value: Variant): Variant;
      property DBColumnName: string read FDBColumnName;
      property EntityPropName: string read FEntityPropName;
      property ORMType: TORMType read FORMType;
      property DBType: string read FDBType;
      property Length: Integer read FLength;
      property IsPK: Boolean read FIsPK;
      property IsString: Boolean read GetIsString;
      property HasSequence: Boolean read FHasSequence;
      property PPropInfo: PPropInfo read FPPropInfo;
  end;

  TORMEntityList = specialize TList<TORMEntity>;

  {TORM}

  TORM = class
    private
      class function GenerateColumnsScript(entity: TORMEntity): string;
      class function GeneratePK(entity: TORMEntity): string;
      class function GenerateSequene(entity: TORMEntity): string;
    public
      class var EntityList: TORMEntityList;
      class function ToScriptCreate(EntityClassName: string): string;
      class function ToScriptAlter(EntityClassName: string): string;
      class function FindORMEntity(EntityClassName: string): TORMEntity;
  end;

  { TORMMapBuilder }

  TORMMapBuilder = class
    private
      function MapField(ADBFieldName, AEntityPropName: string): TORMField;
  public
    function MapModel(AClassOfEntity: TClass; ADBTableName: string): TORMMapBuilder;
    function MapSequenceInt32PK(ADBColumnName, AEntityPropName: string): TORMMapBuilder;
    function MapString(ADBColumnName, AEntityPropName: string; ALenght: Integer): TORMMapBuilder;
    function MapDateTime(ADBColumnName, AEntityPropName: string; NullIfZero: Boolean): TORMMapBuilder;
    function MapInt32(ADBColumnName, AEntityPropName: string): TORMMapBuilder;
    // apesar do nome pode ser usado para outros tipos como double, real...
    function MapDecimal(ADBColumnName, AEntityPropName: string; APrecision, AScale: SmallInt): TORMMapBuilder;
  end;


implementation

{ TORMField }

function TORMField.GetIsString: Boolean;
begin
  Result := (Self.ORMType = ormTypeString) or (Self.ORMType = ormTypeStringNullIfEmpty);
end;

function TORMField.GetIsOrNotNullValueOf(Value: Variant): Variant;
begin

end;

{ TORMEntity }

function TORMEntity.GetCountPK: Integer;
var
  ormField: TORMField;
  c: Integer;
begin
  c := 0;
  for ormField in FieldList do
    if ormField.IsPK then
      Inc(c);

  Result := c;
end;

constructor TORMEntity.Create(AEntityClassName, ADBTableName: string;
  AClassOfEntity: TClass);
begin
  FEntityClassName := AEntityClassName;
  FClassOfEntity := AClassOfEntity;
  FDBTableName := ADBTableName;
  FFieldList := TORMFieldList.Create;
end;

function TORMEntity.GetDBColumnNameOf(ClassPropName: string): string;
var
  item: TORMField;
begin
  Result := '';
  for item in FieldList do
  begin
    if item.EntityPropName = ClassPropName then
    begin
      Result := item.DBColumnName;
      break;
    end;
  end;

  if Result = '' then
    raise Exception.Create('A classe ' + Self.ClassOfEntity.ClassName + ' não possui a propriedade ' + ClassPropName + ' mapeada.');
end;

{ TORM }

class function TORM.GenerateColumnsScript(entity: TORMEntity): string;
var
  i: Integer;
  s: string;
begin
  s := '';
  for i := 0 to entity.FieldList.Count -1 do
  begin
    s := s + '  ' + entity.FieldList[i].DBColumnName + ' ' + entity.FieldList[i].DBType +
      IfThen(entity.FieldList[i].IsPK, ' not null', '') +
      IfThen(i < entity.FieldList.Count -1, ',', '') +
      IfThen(i = entity.FieldList.Count -1, '', LineEnding);
  end;
  Result := s;
end;

class function TORM.GeneratePK(entity: TORMEntity): string;
var
  i: Integer;
  s: string;
  needComma: Boolean;
begin
  needComma := False;
  s := 'alter table  ' + entity.DBTableName + ' add constraint ' +
    entity.DBTableName + '_PK primary key (';
  for i := 0 to entity.FieldList.Count -1 do
  begin

    if entity.FieldList[i].IsPK then
    begin
      if needComma then
        s := s + ', ';

      s := s + entity.FieldList[i].DBColumnName;
      needComma := True;
    end;

  end;
  Result := s + ');';
end;

class function TORM.GenerateSequene(entity: TORMEntity): string;
var
  i: Integer;
  s: string;
begin
  s := '';
  for i := 0 to entity.FieldList.Count -1 do
  begin

    if entity.FieldList[i].HasSequence then
    begin
      s := s + 'create sequence ' + entity.DBTableName + '_SEQUENCE;' + LineEnding;
    end;

  end;
  Result := s;
end;

class function TORM.ToScriptCreate(EntityClassName: string): string;
var
  entity: TORMEntity;
  s: string;
begin
  entity := FindORMEntity(EntityClassName);
  s := 'create table ' + entity.DBTableName + LineEnding + '(' + LineEnding;
  s := s + GenerateColumnsScript(entity);
  s := s + LineEnding + ');' + LineEnding + LineEnding;
  s := s + GeneratePK(entity) + LineEnding + LineEnding;
  s := s + GenerateSequene(entity) + LineEnding + LineEnding;
  Result := s;
end;

class function TORM.ToScriptAlter(EntityClassName: string): string;
var
  entity: TORMEntity;
  i: Integer;
  s: string;
begin
  entity := FindORMEntity(EntityClassName);

  s := '';
  for i := 0 to entity.FieldList.Count -1 do
  begin
    s := s + 'alter table ' + entity.DBTableName;
    s := s + ' add  ' + entity.FieldList[i].DBColumnName + ' ' + entity.FieldList[i].DBType;
    s := s + IfThen(entity.FieldList[i].IsPK, ' not null;', ';') + LineEnding + LineEnding;
  end;
  Result := s;
end;

class function TORM.FindORMEntity(EntityClassName: string): TORMEntity;
var
  entity: TORMEntity;
begin
  Result := nil;
  for entity in TORM.EntityList do
  begin
    if (EntityClassName = entity.EntityClassName) then
    begin
      Result := entity;
      break;
    end;
  end;

  if Result = nil then
    raise Exception.Create(EntityClassName + ' não encontrado.');
end;

{ TORMMapBuilder }

function TORMMapBuilder.MapField(ADBFieldName, AEntityPropName: string
  ): TORMField;
var
  field: TORMField;
  entity: TORMEntity;
begin
  entity := TORM.EntityList.Last;

  field := TORMField.Create;
  field.FDBColumnName := ADBFieldName;
  field.FEntityPropName := AEntityPropName;
  field.FPPropInfo := FindPropInfo(entity.ClassOfEntity, AEntityPropName) ;

  entity.FieldList.Add(field);

  Result := field;
end;

function TORMMapBuilder.MapModel(AClassOfEntity: TClass; ADBTableName: string): TORMMapBuilder;
var
  entity: TORMEntity;
begin
  entity := TORMEntity.Create(AClassOfEntity.ClassName, ADBTableName, AClassOfEntity);

  TORM.EntityList.Add(entity);

  Result := Self;
end;

function TORMMapBuilder.MapString(ADBColumnName, AEntityPropName: string; ALenght: Integer
  ): TORMMapBuilder;
var
  field: TORMField;
begin
  field := MapField(ADBColumnName, AEntityPropName);
  field.FLength := ALenght;
  field.FDBType := 'VarChar(' + IntToStr(ALenght) + ')';
  field.FORMType := ormTypeString;
  Result := Self;
end;

function TORMMapBuilder.MapSequenceInt32PK(ADBColumnName, AEntityPropName: string
  ): TORMMapBuilder;
var
  field: TORMField;
begin
  field := MapField(ADBColumnName, AEntityPropName);
  field.FDBType := 'Integer';
  field.FIsPK := True;
  field.FHasSequence := True;
  field.FORMType := ormTypeInt32;
  Result := Self;
end;

function TORMMapBuilder.MapDateTime(ADBColumnName, AEntityPropName: string;
  NullIfZero: Boolean): TORMMapBuilder;
var
  field: TORMField;
begin
  field := MapField(ADBColumnName, AEntityPropName);
  field.FDBType := 'Timestamp';

  if NullIfZero then
    field.FORMType := ormTypeTimestampNullIfZero
  else
    field.FORMType := ormTypeTimestamp;

  Result := Self;
end;

function TORMMapBuilder.MapInt32(ADBColumnName, AEntityPropName: string
  ): TORMMapBuilder;
var
  field: TORMField;
begin
  field := MapField(ADBColumnName, AEntityPropName);
  field.FDBType := 'Integer';
  field.FORMType := ormTypeInt32;
  Result := Self;
end;

function TORMMapBuilder.MapDecimal(ADBColumnName, AEntityPropName: string;
  APrecision, AScale: SmallInt): TORMMapBuilder;
var
  field: TORMField;
begin
  field := MapField(ADBColumnName, AEntityPropName);
  field.FDBType := 'Decimal(' + APrecision.ToString + ', ' + AScale.ToString + ')';
  field.FORMType := ormTypeDecimal;
  Result := Self;
end;

initialization

TORM.EntityList := TORMEntityList.Create();

end.                             f

