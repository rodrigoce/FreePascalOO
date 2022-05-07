unit mini_orm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, TypInfo, Generics.Collections,
  StrUtils;

type

  {Records}
  {TMultStrResult = record
    Result1: string;
    Result2: string;
  end;}

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
      function FCountPK: Integer;
    public
      property EntityClassName: string read FEntityClassName;
      property ClassOfEntity: TClass read FClassOfEntity;
      property DBTableName: string read FDBTableName;
      //
      property FieldList: TORMFieldList read FFieldList;
      property CountPK: Integer read FCountPK;
      //
      constructor Create(AEntityClassName, ADBTableName: string; AClassOfEntity: TClass);

  end;

  {TORMField}

  TORMField = class
    private
      FDBColumnName: string;
      FEntityFieldName: string;
      FDBType: string;
      FLength: Integer;
      FIsPK: Boolean;
      FHasSequence: Boolean;
      FPPropInfo: PPropInfo;
    public
      property DBColumnName: string read FDBColumnName;
      property EntityFieldName: string read FEntityFieldName;
      property DBType: string read FDBType;
      property Length: Integer read FLength;
      property IsPK: Boolean read FIsPK;
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
      class function ToScript(EntityClassName: string): string;
      class function FindORMEntity(EntityClassName: string): TORMEntity;
  end;

  { TORMMapBuilder }

  TORMMapBuilder = class
    private
      function MapField(ADBFieldName, AEntityFieldName: string): TORMField;
  public
    function MapModel(AClassOfEntity: TClass; ADBTableName: string): TORMMapBuilder;
    function MapSequenceInt32PK(ADBFieldName, AEntityFieldName: string): TORMMapBuilder;
    function MapString(ADBFieldName, AEntityFieldName: string; ALenght: Integer): TORMMapBuilder;
    function MapDateTime(ADBFieldName, AEntityFieldName: string): TORMMapBuilder;
    function MapInt32(ADBFieldName, AEntityFieldName: string): TORMMapBuilder;
  end;


implementation

{ TORMEntity }

function TORMEntity.FCountPK: Integer;
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
      s := s + ' create sequence SEQUENCE_' + entity.DBTableName + ';' + LineEnding;
    end;

  end;
  Result := s;
end;

class function TORM.ToScript(EntityClassName: string): string;
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

function TORMMapBuilder.MapField(ADBFieldName, AEntityFieldName: string
  ): TORMField;
var
  field: TORMField;
  entity: TORMEntity;
begin
  entity := TORM.EntityList.Last;

  field := TORMField.Create;
  field.FDBColumnName := ADBFieldName;
  field.FEntityFieldName := AEntityFieldName;
  field.FPPropInfo := FindPropInfo(entity.ClassOfEntity, AEntityFieldName) ;

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

function TORMMapBuilder.MapString(ADBFieldName, AEntityFieldName: string; ALenght: Integer
  ): TORMMapBuilder;
var
  field: TORMField;
begin
  field := MapField(ADBFieldName, AEntityFieldName);
  field.FLength := ALenght;
  field.FDBType := 'VarChar(' + IntToStr(ALenght) + ')';
  Result := Self;
end;

function TORMMapBuilder.MapSequenceInt32PK(ADBFieldName, AEntityFieldName: string
  ): TORMMapBuilder;
var
  field: TORMField;
begin
  field := MapField(ADBFieldName, AEntityFieldName);
  field.FDBType := 'Integer';
  field.FIsPK := True;
  field.FHasSequence := True;
  Result := Self;
end;

function TORMMapBuilder.MapDateTime(ADBFieldName, AEntityFieldName: string): TORMMapBuilder;
var
  field: TORMField;
begin
  field := MapField(ADBFieldName, AEntityFieldName);
  field.FDBType := 'Timestamp';
  Result := Self;
end;

function TORMMapBuilder.MapInt32(ADBFieldName, AEntityFieldName: string
  ): TORMMapBuilder;
var
  field: TORMField;
begin
  field := MapField(ADBFieldName, AEntityFieldName);
  field.FDBType := 'Integer';
  Result := Self;
end;

initialization

TORM.EntityList := TORMEntityList.Create();

end.                             f

