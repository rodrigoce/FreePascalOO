unit usuario_dal;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Contnrs, DB, SQLDB, Dialogs, BufDataset,
  Generics.Collections, dal_base, usuario_entity, usuario_filter,
  filter_composer,  application_functions, db_context;

type

  { TUsuarioDAL }

  TUsuarioDAL = class(specialize TDALBase<TUsuarioEntity>)
    public
      function GetUserCount: Integer;
      procedure SearchUsuarios(Buffer: TBufDataset; Filter: TUsuarioFilter);
      function FindByFilter(Params: Variant): specialize TObjectList<TUsuarioEntity>;
  end;

implementation

{ TUsuarioDAL }

function TUsuarioDAL.GetUserCount: Integer;
var
  q: TSQLQuery;
begin
  q := DbContext.CreateSQLQuery;
  q.SQL.Text := 'select count(1) from usuario';
  q.Open;
  Result := q.Fields[0].AsInteger;
  q.Close;
  q.Free;
end;

procedure TUsuarioDAL.SearchUsuarios(Buffer: TBufDataset;
  Filter: TUsuarioFilter);
var
  query: TSQLQuery;
  filterComposer: TFilterComposer;
begin
  query := DbContext.CreateSQLQuery;
  filterComposer := TFilterComposer.Create;
  query.SQL.Text := 'select * from usuario';

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

function TUsuarioDAL.FindByFilter(Params: Variant): specialize TObjectList<
  TUsuarioEntity>;
var
  i: Integer;
  listOfObjects: TFPObjectList;
  listOfEntity: specialize TObjectList<TUsuarioEntity>;
begin
  listOfObjects := FindByFilterRaw(Params);
  listOfEntity := specialize TObjectList<TUsuarioEntity>.Create(True);
  for i := 0 to listOfObjects.Count -1 do
  begin
    listOfEntity.Add(TUsuarioEntity(listOfObjects[i]));
  end;
  listOfObjects.Free;
  Result := listOfEntity;
end;

end.

