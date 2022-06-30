unit produto_dal;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, dal_base, produto_entity, produto_filter, filter_composer,
  application_functions, DB, SQLDB, Dialogs, BufDataset;

type

  { TProdutoDAL }

  TProdutoDAL = class(specialize TDALBase<TProdutoEntity>)
    public
      procedure SearchProdutos(Target: TBufDataset; Filter: TProdutoFilter);
  end;

implementation

{ TProdutoDAL }

procedure TProdutoDAL.SearchProdutos(Target: TBufDataset; Filter: TProdutoFilter
  );
var
  query: TSQLQuery;
  filterComposer: TFilterComposer;
begin
  query := Self.CreateSQLQuery;
  filterComposer := TFilterComposer.Create;
  query.SQL.Text := 'select * from produto';

  filterComposer.IsNotEmptyThenEquals(Filter.Codigo, 'CODIGO');
  filterComposer.IsNotEmptyThenLike(RemoveAccent(Filter.Nome), 'NOME_PP');
  filterComposer.ApplyOnQuery(query);

  query.Open;

  Target.CopyFromDataset(query);
  Target.First;

  query.Close;
  query.Free;
  filterComposer.Free;
end;

end.

