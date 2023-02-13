unit test_dal;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Generics.Collections, DB, SQLDB, Dialogs,
  Contnrs, BufDataset, dal_base, test_entity,
  db_context;

type

  { TTestDAL }

  TTestDAL = class(specialize TDALBase<TTestEntity>)
    public
      //procedure SearchTestss(Buffer: TBufDataset; Filter: TTestsFilter);
      function FindByFilter(Params: Variant): specialize TObjectList<TTestEntity>;
  end;

implementation

{ TTestDAL }

{procedure TTestDAL.SearchTestss(Buffer: TBufDataset;
  Filter: TTestsFilter);
var
  query: TSQLQuery;
  filterComposer: TFilterComposer;
begin
  query := DbContext.CreateSQLQuery;
  filterComposer := TFilterComposer.Create;
  query.SQL.Text := 'select * from tests';

  filterComposer.IsNotEmptyThenEquals(Filter.Codigo, 'CODIGO');
  filterComposer.IsNotEmptyThenLike(PPConvert(Filter.Nome), 'NOME_PP');
  filterComposer.IsEqualsThenEquals(Filter.Situacao, 'A', 'SITUACAO');
  filterComposer.IsEqualsThenEquals(Filter.Situacao, 'I', 'SITUACAO');
  filterComposer.ApplyOnQuery(query);

  query.Open;

  Buffer.CopyFromDataset(query);
  Buffer.First;

  query.Close;
  query.Free;
  filterComposer.Free;
end;
}

function TTestDAL.FindByFilter(Params: Variant): specialize TObjectList<
  TTestEntity>;
var
  i: Integer;
  listOfObjects: TFPObjectList;
  listOfEntity: specialize TObjectList<TTestEntity>;
begin
  listOfObjects := FindByFilterRaw(Params);
  listOfEntity := specialize TObjectList<TTestEntity>.Create(True);
  for i := 0 to listOfObjects.Count -1 do
  begin
    listOfEntity.Add(TTestEntity(listOfObjects[i]));
  end;
  listOfObjects.Free;
  Result := listOfEntity;
end;


end.

