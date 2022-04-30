unit orm;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Dialogs, {fgl,} TypInfo, Generics.Collections,
  StrUtils;

type

  {Records}
  TMultStrResult = record
    Result1: string;
    Result2: string;
  end;

  {Forward Declarations}

  TORMField = class;

  {Types}

  TORMFieldList = specialize TList<TORMField>;

  {TORMTable}

  TORMTable = class
    public
      ModelClassName: string;
      ClassOfTObject: TClass;
      DBTableName: string;
      //
      FieldList: TORMFieldList;

  end;

  {TORMField}

  TORMField = class
    public
      DBColumnName: string;
      ClassFieldName: string;
      DBType: string;
      Lenght: Integer;
      IsPK: Boolean;
      HasSequence: Boolean;
      PPropInfo: PPropInfo;
  end;

  TORMTableList = specialize TList<TORMTable>;

  {TORM}

  TORM = class
    private
      class function GenerateColumnsScript(table: TORMTable): string;
      class function GeneratePK(table: TORMTable): string;
      class function GenerateSequene(table: TORMTable): string;
    public
      class var TableList: TORMTableList;
      class function ToScript(ModelClassName: string): string;
      class function FindTableByName(ModelClassName: string): TORMTable;
  end;

  { TORMMapBuilder }

  TORMMapBuilder = class
    private
      function MapField(DBFieldName, ClassFieldName: string): TORMField;
  public
    function MapModel(modelClass: TClass; DBTableName: string): TORMMapBuilder;
    function MapSequenceInt32PK(DBFieldName, ClassFieldName: string): TORMMapBuilder;
    function MapString(DBFieldName, ClassFieldName: string; Lenght: Integer): TORMMapBuilder;
    function MapDateTime(DBFieldName, ClassFieldName: string): TORMMapBuilder;
    function MapInt32(DBFieldName, ClassFieldName: string): TORMMapBuilder;
  end;


implementation

{ TORM }

class function TORM.GenerateColumnsScript(table: TORMTable): string;
var
  i: Integer;
  s: string;
begin
  s := '';
  for i := 0 to table.FieldList.Count -1 do
  begin
    s := s + '  ' + table.FieldList[i].DBColumnName + ' ' + table.FieldList[i].DBType +
      IfThen(table.FieldList[i].IsPK, ' not null', '') +
      IfThen(i < table.FieldList.Count -1, ',', '') +
      IfThen(i = table.FieldList.Count -1, '', LineEnding);
  end;
  Result := s;
end;

class function TORM.GeneratePK(table: TORMTable): string;
var
  i: Integer;
  s: string;
  needComma: Boolean;
begin
  needComma := False;
  s := 'alter table  ' + table.DBTableName + ' add constraint ' +
    table.DBTableName + '_PK primary key (';
  for i := 0 to table.FieldList.Count -1 do
  begin

    if table.FieldList[i].IsPK then
    begin
      if needComma then
        s := s + ', ';

      s := s + table.FieldList[i].DBColumnName;
      needComma := True;
    end;

  end;
  Result := s + ');';
end;

class function TORM.GenerateSequene(table: TORMTable): string;
var
  i: Integer;
  s: string;
begin
  s := '';
  for i := 0 to table.FieldList.Count -1 do
  begin

    if table.FieldList[i].HasSequence then
    begin
      s := s + ' create sequence SEQUENCE_' + table.DBTableName + ';' + LineEnding;
    end;

  end;
  Result := s;
end;

class function TORM.ToScript(ModelClassName: string): string;
var
  table: TORMTable;
  s: string;
begin
  table := FindTableByName(ModelClassName);
  s := 'create table ' + table.DBTableName + LineEnding + '(' + LineEnding;
  s := s + GenerateColumnsScript(table);
  s := s + LineEnding + ');' + LineEnding + LineEnding;
  s := s + GeneratePK(table) + LineEnding + LineEnding;
  s := s + GenerateSequene(table) + LineEnding + LineEnding;
  Result := s;
end;

class function TORM.FindTableByName(ModelClassName: string): TORMTable;
var
  table: TORMTable;
begin
  Result := nil;
  for table in TORM.TableList do
  begin
    if (ModelClassName = table.ModelClassName) then
    begin
      Result := table;
      break;
    end;
  end;

  if Result = nil then
    raise Exception.Create(ModelClassName + ' não encontrado.');
end;

{ TORMMapBuilder }

function TORMMapBuilder.MapField(DBFieldName, ClassFieldName: string
  ): TORMField;
var
  field: TORMField;
  table: TORMTable;
begin
  table := TORM.TableList.Last;

  field := TORMField.Create;
  field.DBColumnName := DBFieldName;
  field.ClassFieldName := ClassFieldName;
  field.PPropInfo := FindPropInfo(table.ClassOfTObject, ClassFieldName) ;

  table.FieldList.Add(field);

  Result := field;
end;

function TORMMapBuilder.MapModel(modelClass: TClass; DBTableName: string): TORMMapBuilder;
var
  table: TORMTable;
begin
  table := TORMTable.Create;
  table.ClassOfTObject := modelClass;
  table.DBTableName := DBTableName;
  table.ModelClassName := modelClass.ClassName;
  table.FieldList := TORMFieldList.Create();

  TORM.TableList.Add(table);

  Result := Self;
end;

function TORMMapBuilder.MapString(DBFieldName, ClassFieldName: string; Lenght: Integer
  ): TORMMapBuilder;
var
  field: TORMField;
begin
  field := MapField(DBFieldName, ClassFieldName);
  field.Lenght := Lenght;
  field.DBType := 'VarChar(' + IntToStr(Lenght) + ')';
  Result := Self;
end;

function TORMMapBuilder.MapSequenceInt32PK(DBFieldName, ClassFieldName: string
  ): TORMMapBuilder;
var
  field: TORMField;
begin
  field := MapField(DBFieldName, ClassFieldName);
  field.DBType := 'Integer';
  field.IsPK := True;
  field.HasSequence := True;
  Result := Self;
end;

function TORMMapBuilder.MapDateTime(DBFieldName, ClassFieldName: string): TORMMapBuilder;
var
  field: TORMField;
begin
  field := MapField(DBFieldName, ClassFieldName);
  field.DBType := 'Timestamp';
  Result := Self;
end;

function TORMMapBuilder.MapInt32(DBFieldName, ClassFieldName: string
  ): TORMMapBuilder;
var
  field: TORMField;
begin
  field := MapField(DBFieldName, ClassFieldName);
  field.DBType := 'Integer';
  Result := Self;
end;

initialization

TORM.TableList := TORMTableList.Create();

end.                             f

