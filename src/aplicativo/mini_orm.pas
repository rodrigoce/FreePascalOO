unit mini_orm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, TypInfo, Generics.Collections,
  StrUtils, Variants, LConvEncoding;

type
  { Enum }

  TORMType = (
    ormTypeInt32PK, ormTypeInt32, ormTypeInt32NullIfZero,
    ormTypeDateTime, ormTypeDateTimeNullIfZero,
    ormTypeString, ormTypeStringNullIfEmpty,
    ormTypeDecimal);

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
      class procedure CloneTo(Source, Target: TObject; ORMEntity: TORMEntity);
  end;

  {TORMField}

  TORMField = class
    private
      FDBColumnName: string;
      FEntityPropName: string;
      FDBType: string;
      FLength: Integer;
      FHasSequence: Boolean;
      FORMType: TORMType;
      FPPropInfo: PPropInfo;
      FPrecision: Integer;
      FScale: Integer;
      function GetIsString: Boolean;
    public
      function ProcessedParamValue(Value: Variant): Variant;

      property DBColumnName: string read FDBColumnName;
      property EntityPropName: string read FEntityPropName;
      property ORMType: TORMType read FORMType;
      property DBType: string read FDBType;
      property Length: Integer read FLength;
      property IsString: Boolean read GetIsString;
      property HasSequence: Boolean read FHasSequence;
      property Precision: Integer read FPrecision;
      property Scale: Integer read FScale;
      property PPropInfo: PPropInfo read FPPropInfo;
  end;

  TORMEntityList = specialize TList<TORMEntity>;

  {TORM}

  TORM = class
    private
      class function GenerateColumnsScript(entity: TORMEntity): string;
      class function GeneratePK(entity: TORMEntity): string;
      class function GenerateFK(entity: TORMEntity): string;
      class function GenerateSequene(entity: TORMEntity): string;
      class function GenerateLogTable(entity: TORMEntity): string;
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
    //
    function MapInt32PK(ADBColumnName, AEntityPropName: string): TORMMapBuilder;
    function MapInt32(ADBColumnName, AEntityPropName: string; NullIfZero: Boolean): TORMMapBuilder;
    //
    function MapString(ADBColumnName, AEntityPropName: string; ALenght: Integer; NullIfEmpty: Boolean): TORMMapBuilder;
    //
    function MapDateTime(ADBColumnName, AEntityPropName: string; NullIfZero: Boolean): TORMMapBuilder;
    // apesar do nome pode ser usado para outros tipos como double, real...
    function MapDecimal(ADBColumnName, AEntityPropName: string; APrecision, AScale: SmallInt): TORMMapBuilder;
  end;

  // retorna string ou Null
  function VarToStrSQLParam(OrmField: TORMField; Value: Variant): Variant;


implementation

function VarToStrSQLParam(OrmField: TORMField; Value: Variant): Variant;
begin
  if Value = Null then
    Result := Null
  else if OrmField.ORMType in [ormTypeDateTime, ormTypeDateTimeNullIfZero] then
  begin
    Result := FormatDateTime('DD/MM/YYYY hh:nn:ss', Value, []);
  end
  else
    Result := VarToStr(Value);
end;


{ TORMField }

function TORMField.GetIsString: Boolean;
begin
  Result := (Self.ORMType = ormTypeString) or (Self.ORMType = ormTypeStringNullIfEmpty);
end;

function TORMField.ProcessedParamValue(Value: Variant): Variant;
begin
  if (Self.ORMType in [ormTypeInt32NullIfZero, ormTypeDateTimeNullIfZero]) and (Value = 0) then
    Result := Null
  else if (Self.ORMType = ormTypeStringNullIfEmpty) and (Value = '') then
    Result := Null
  else
    Result := Value;
end;

{ TORMEntity }

function TORMEntity.GetCountPK: Integer;
var
  ormField: TORMField;
  c: Integer;
begin
  c := 0;
  for ormField in FieldList do
    if ormField.FORMType = ormTypeInt32PK then
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

class procedure TORMEntity.CloneTo(Source, Target: TObject; ORMEntity: TORMEntity);
var
  ormField: TORMField;
begin
  for ormField in ORMEntity.FieldList do
  begin
    if ormField.PPropInfo^.SetProc <> nil then
      SetPropValue(Target, ormField.PPropInfo, GetPropValue(Source, ormField.PPropInfo));
  end;
end;

{ TORM }

class function TORM.GenerateColumnsScript(entity: TORMEntity): string;
var
  i: Integer;
  s: string = '';
  nulability: string = '';
begin
  for i := 0 to entity.FieldList.Count -1 do
  begin
    if entity.FieldList[i].FORMType in [ormTypeInt32PK, ormTypeInt32, ormTypeDateTime, ormTypeString, ormTypeDecimal] then
      nulability := ' not null'
    else if entity.FieldList[i].FORMType in [ormTypeDateTimeNullIfZero, ormTypeInt32NullIfZero, ormTypeStringNullIfEmpty] then
      nulability := ''
    else
      raise Exception.Create(Format('Nulabilidade da coluna %s não mapeada', [entity.FieldList[i].DBColumnName]));

    s := s + '  ' + entity.FieldList[i].DBColumnName + ' ' + entity.FieldList[i].DBType +
      nulability +
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
  s := 'alter table ' + entity.DBTableName + ' add constraint ' +
    entity.DBTableName + '_PK primary key (';
  for i := 0 to entity.FieldList.Count -1 do
  begin

    if entity.FieldList[i].ORMType = ormTypeInt32PK then
    begin
      if needComma then
        s := s + ', ';

      s := s + entity.FieldList[i].DBColumnName;
      needComma := True;
    end;

  end;
  Result := s + ');';
end;

class function TORM.GenerateFK(entity: TORMEntity): string;
var
  s: string;
begin
  s := 'alter table ' + entity.DBTableName + ' add constraint SITUACAO_REG_' +
    entity.DBTableName + '_FK foreign key (SITUACAO) references SITUACAO_REG (SITUACAO);';
  Result := s;
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

class function TORM.GenerateLogTable(entity: TORMEntity): string;
var
  s, logTabName: string;
begin
  logTabName := entity.DBTableName + '_LOG';

  s := 'create table ' + logTabName + LineEnding + '(' + LineEnding;
  s := s + '  DATA_HORA Timestamp not null,' + LineEnding;
  s := s + '  OPERACAO varchar(1) not null,' + LineEnding;
  s := s + '  ID_USUARIO Integer,' + LineEnding;
  s := s + '  ID_PK Integer not null,' + LineEnding;
  s := s + '  NOME_COLUNA varchar(60) not null,' + LineEnding;
  s := s + '  VALOR_ANTERIOR varchar(500),' + LineEnding;
  s := s + '  VALOR_NOVO varchar(500),' + LineEnding;
  s := s + '  VALOR_ANTERIOR_B BLOB,' + LineEnding;
  s := s + '  VALOR_NOVO_B BLOB' + LineEnding;
  s := s + ');' + LineEnding + LineEnding;

  s := s + 'alter table ' + logTabName + ' add constraint USUARIO_' + logTabName + '_FK foreign key (ID_USUARIO) references USUARIO (ID);' + LineEnding;
  s := s + 'alter table ' + logTabName + ' add constraint ' + entity.DBTableName + '_' + logTabName + '2_FK foreign key (ID_PK) references ' + entity.DBTableName + ' (ID);' + LineEnding + LineEnding;

  s := s + 'create index ' + entity.DBTableName + '_LOG_' + 'IDX_DATA_HORA on ' + entity.DBTableName + '_LOG (DATA_HORA);' + LineEnding;
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
  s := s + GenerateFK(entity) + LineEnding + LineEnding;
  s := s + GenerateSequene(entity) + LineEnding;
  s := s + GenerateLogTable(entity);
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
    s := s + IfThen(entity.FieldList[i].ORMType = ormTypeInt32PK, ' not null;', ';') + LineEnding + LineEnding;
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

function TORMMapBuilder.MapString(ADBColumnName, AEntityPropName: string;
  ALenght: Integer; NullIfEmpty: Boolean): TORMMapBuilder;
var
  field: TORMField;
begin
  field := MapField(ADBColumnName, AEntityPropName);
  field.FLength := ALenght;
  field.FDBType := 'VarChar(' + IntToStr(ALenght) + ')';

  if NullIfEmpty then
    field.FORMType := ormTypeStringNullIfEmpty
  else
    field.FORMType := ormTypeString;

  Result := Self;
end;

function TORMMapBuilder.MapInt32PK(ADBColumnName, AEntityPropName: string
  ): TORMMapBuilder;
var
  entity: TORMEntity;
  field: TORMField;
begin
  entity := TORM.EntityList.Last;
  if entity.GetCountPK > 1 then
    raise Exception.Create('Não foi implementado chave composta no mini orm.');

  field := MapField(ADBColumnName, AEntityPropName);
  field.FDBType := 'Integer';
  field.FHasSequence := True;
  field.FORMType := ormTypeInt32PK;
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
    field.FORMType := ormTypeDateTimeNullIfZero
  else
    field.FORMType := ormTypeDateTime;

  Result := Self;
end;

function TORMMapBuilder.MapInt32(ADBColumnName, AEntityPropName: string;
  NullIfZero: Boolean): TORMMapBuilder;
var
  field: TORMField;
begin
  field := MapField(ADBColumnName, AEntityPropName);
  field.FDBType := 'Integer';

  if NullIfZero then
    field.FORMType := ormTypeInt32NullIfZero
  else
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
  field.FPrecision := APrecision;
  field.FScale := AScale;
  Result := Self;
end;

initialization

TORM.EntityList := TORMEntityList.Create();

end.                             f

