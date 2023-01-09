unit filter_composer;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, LazUTF8, Generics.Collections, SQLDB;

type

  { TFilterComposer }

  TFilterComposer = class
  private
    FWhere: string;
    FParamsList: specialize TList<Variant>;
    procedure AddOperator;
  public
    constructor Create;
    destructor Destory;

    // se Value nao for vazio, adiciona um filtro onde DBFieldName = Value
    procedure IsNotEmptyThenEquals(Value, DBFieldName: string);
    // se Value nao for vazio, adiciona um filtro onde DBFieldName like '%Value%'
    procedure IsNotEmptyThenLike(Value, DBFieldName: string);
    // se Value1 = Value 2, adiciona um filtro onde DBFieldName = Value1
    procedure IsEqualsThenEquals(Value1, Value2: string; DBFieldName: string);
    //
    procedure IsBetween(Value1, Value2: TDateTime; DBFieldName: string);
    //
    procedure ApplyOnQuery(Query: TSQLQuery);
  end;

implementation

{ TFilterComposer }

procedure TFilterComposer.AddOperator;
begin
  if FWhere = '' then
    FWhere := 'Where '
  else
    FWhere := FWhere + LineEnding + 'and ';
end;

constructor TFilterComposer.Create;
begin
  FParamsList := specialize TList<Variant>.Create;
end;

destructor TFilterComposer.Destory;
begin
  FParamsList.Free;

  inherited;
end;

procedure TFilterComposer.IsNotEmptyThenEquals(Value, DBFieldName: string);
begin
  if (UTF8Trim(Value)) <> '' then
  begin
    AddOperator;
    FWhere := FWhere + DBFieldName + ' = :' + DBFieldName;
    FParamsList.Add(Value);
  end;
end;

procedure TFilterComposer.IsNotEmptyThenLike(Value, DBFieldName: string);
begin
  if (UTF8Trim(Value)) <> '' then
  begin
    AddOperator;
    FWhere := FWhere + DBFieldName + ' like ''%''||:' + DBFieldName + '||''%''';
    FParamsList.Add(Value);
  end;
end;

procedure TFilterComposer.IsEqualsThenEquals(Value1, Value2: string;
  DBFieldName: string);
begin
  if Value1 = Value2 then
  begin
    AddOperator;
    FWhere := FWhere + DBFieldName + ' = :' + DBFieldName;
    FParamsList.Add(Value1);
  end;
end;

procedure TFilterComposer.IsBetween(Value1, Value2: TDateTime;
  DBFieldName: string);
begin
  AddOperator;
  FWhere := FWhere + DBFieldName + ' between :' + DBFieldName + '1 and :' + DBFieldName + '2';
  FParamsList.Add(Value1);
  FParamsList.Add(Value2);
end;

procedure TFilterComposer.ApplyOnQuery(Query: TSQLQuery);
var
  i: Integer;
begin
  Query.SQL.Add(FWhere);

  for i := 0 to FParamsList.Count -1 do
    Query.Params[i].Value := FParamsList.Items[i];
end;

end.

