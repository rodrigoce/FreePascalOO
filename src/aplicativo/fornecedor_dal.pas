unit fornecedor_dal;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Generics.Collections, DB, SQLDB, Dialogs,
  Contnrs, BufDataset, dal_base, fornecedor_entity, fornecedor_filter,
  filter_composer, application_functions, db_context;

type

  { TFornecedorDAL }

  TFornecedorDAL = class(specialize TDALBase<TFornecedorEntity>)
    public
      procedure SearchFornecedores(Buffer: TBufDataset; Filter: TFornecedorFilter);
      function FindByFilter(Params: Variant): specialize TObjectList<TFornecedorEntity>;
  end;

implementation

{ TFornecedorDAL }

procedure TFornecedorDAL.SearchFornecedores(Buffer: TBufDataset;
  Filter: TFornecedorFilter);
var
  query: TSQLQuery;
  filterComposer: TFilterComposer;
begin
  query := DbContext.CreateSQLQuery;
  filterComposer := TFilterComposer.Create;
  query.SQL.Text := 'select * from fornecedor';

  filterComposer.IsNotEmptyThenLike(PPConvert(Filter.Nome), 'NOME_PP');
  filterComposer.IsNotEmptyThenLike(PPConvert(Filter.Contato), 'CONTATOS_PP');
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

function TFornecedorDAL.FindByFilter(Params: Variant): specialize TObjectList<
  TFornecedorEntity>;
var
  i: Integer;
  listOfObjects: TFPObjectList;
  listOfEntity: specialize TObjectList<TFornecedorEntity>;
begin
  listOfObjects := FindByFilterRaw(Params);
  listOfEntity := specialize TObjectList<TFornecedorEntity>.Create(True);
  for i := 0 to listOfObjects.Count -1 do
  begin
    listOfEntity.Add(TFornecedorEntity(listOfObjects[i]));
  end;
  listOfObjects.Free;
  Result := listOfEntity;
end;


end.

