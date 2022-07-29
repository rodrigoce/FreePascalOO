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
      procedure Teste;
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

procedure TProdutoDAL.Teste;
var
  q: TSQLQuery;
begin
  q := CreateSQLQuery;
  q.SQL.Text := 'update produto set margem_lucro = 1.12345';
  q.SQL.Text := 'update produto set margem_lucro = :n';
  q.ParamByName('n').Value := 1.12347;
  //q.ParamByName('n').Precision := 15;
  //q.ParamByName('n').NumericScale := 5;
  //q.ParamByName('n').Size := 15;
  q.ParamByName('n').DataType := ftFMTBcd;
  q.ExecSQL;
  GetTransaction.Commit;
  q.SQL.Text := 'select margem_lucro from produto';
  q.Open;
  ShowMessage(q.Fields[0].AsString);
  q.Close;
  q.Free;
  ;
end;

end.

