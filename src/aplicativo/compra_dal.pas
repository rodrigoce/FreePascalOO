unit compra_dal;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Generics.Collections, DB, SQLDB, Dialogs,
  Contnrs, BufDataset, dal_base, compra_entity, compra_filter,
  filter_composer, application_functions, db_context;

type

  { TCompraDAL }

  TCompraDAL = class(specialize TDALBase<TCompraEntity>)
    public
      procedure SearchCompras(Buffer: TBufDataset; Filter: TCompraFilter);
      function FindByFilter(Params: Variant): specialize TObjectList<TCompraEntity>;
  end;

implementation

{ TCompraDAL }

procedure TCompraDAL.SearchCompras(Buffer: TBufDataset;
  Filter: TCompraFilter);
var
  query: TSQLQuery;
  filterComposer: TFilterComposer;
begin
  query := DbContext.CreateSQLQuery;
  filterComposer := TFilterComposer.Create;
  query.SQL.Text := 'select * from compra';

  filterComposer.IsEqualsThenEquals(Filter.Situacao, 'A', 'SITUACAO');
  filterComposer.IsEqualsThenEquals(Filter.Situacao, 'E', 'SITUACAO');
  filterComposer.IsBetween(Filter.DataIni, Filter.DataFim, 'DATA');
  filterComposer.ApplyOnQuery(query);

  query.Open;

  Buffer.CopyFromDataset(query);
  Buffer.First;

  query.Close;
  query.Free;
  filterComposer.Free;
end;

function TCompraDAL.FindByFilter(Params: Variant): specialize TObjectList<
  TCompraEntity>;
var
  i: Integer;
  listOfObjects: TFPObjectList;
  listOfEntity: specialize TObjectList<TCompraEntity>;
begin
  listOfObjects := FindByFilterRaw(Params);
  listOfEntity := specialize TObjectList<TCompraEntity>.Create(True);
  for i := 0 to listOfObjects.Count -1 do
  begin
    listOfEntity.Add(TCompraEntity(listOfObjects[i]));
  end;
  listOfObjects.Free;
  Result := listOfEntity;
end;


end.

