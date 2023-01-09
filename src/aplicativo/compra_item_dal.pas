unit compra_item_dal;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, Generics.Collections, Dialogs,
  Contnrs, dal_base, compra_item_entity;

type

  { TCompraItemDAL }

  TCompraItemDAL = class(specialize TDALBase<TCompraItemEntity>)
    public
      {procedure SearchCompraItems(Buffer: TBufDataset; Filter: TCompraItemFilter);}
      function FindByFilter(Params: Variant): specialize TObjectList<TCompraItemEntity>;
  end;

implementation

{ TCompraItemDAL }

{procedure TCompraItemDAL.SearchCompraItems(Buffer: TBufDataset;
  Filter: TCompraItemFilter);
var
  query: TSQLQuery;
  filterComposer: TFilterComposer;
begin
  query := Self.CreateSQLQuery;
  filterComposer := TFilterComposer.Create;
  query.SQL.Text := 'select * from compraItem';

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
end;}

function TCompraItemDAL.FindByFilter(Params: Variant): specialize TObjectList<
  TCompraItemEntity>;
var
  i: Integer;
  listOfObjects: TFPObjectList;
  listOfEntity: specialize TObjectList<TCompraItemEntity>;
begin
  listOfObjects := FindByFilterRaw(Params);
  listOfEntity := specialize TObjectList<TCompraItemEntity>.Create(True);
  for i := 0 to listOfObjects.Count -1 do
  begin
    listOfEntity.Add(TCompraItemEntity(listOfObjects[i]));
  end;
  listOfObjects.Free;
  Result := listOfEntity;
end;


end.

