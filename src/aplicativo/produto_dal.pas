unit produto_dal;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Generics.Collections, DB, SQLDB, Dialogs,
  Contnrs, BufDataset, dal_base, produto_entity, produto_filter,
  filter_composer, application_functions, db_context;

type

  { TProdutoDAL }

  TProdutoDAL = class(specialize TDALBase<TProdutoEntity>)
    public
      procedure SearchProdutos(Buffer: TBufDataset; Filter: TProdutoFilter);
      function FindByFilter(Params: Variant): specialize TObjectList<TProdutoEntity>;
  end;

implementation

{ TProdutoDAL }

procedure TProdutoDAL.SearchProdutos(Buffer: TBufDataset;
  Filter: TProdutoFilter);
var
  query: TSQLQuery;
  filterComposer: TFilterComposer;
begin
  query := DbContext.CreateSQLQuery;
  filterComposer := TFilterComposer.Create;
  query.SQL.Text := 'select * from produto';

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

function TProdutoDAL.FindByFilter(Params: Variant): specialize TObjectList<
  TProdutoEntity>;
var
  i: Integer;
  listOfObjects: TFPObjectList;
  listOfEntity: specialize TObjectList<TProdutoEntity>;
begin
  listOfObjects := FindByFilterRaw(Params);
  listOfEntity := specialize TObjectList<TProdutoEntity>.Create(True);
  for i := 0 to listOfObjects.Count -1 do
  begin
    listOfEntity.Add(TProdutoEntity(listOfObjects[i]));
  end;
  listOfObjects.Free;
  Result := listOfEntity;
end;


end.

