unit produto_dal;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, dal_base, produto_entity, DB, SQLDB, Dialogs, BufDataset;

type

  { TProdutoDAL }

  TProdutoDAL = class(specialize TDALBase<TProdutoEntity>)
    public
      procedure LoadPesquisaProdutos(Target: TBufDataset);
  end;

implementation

{ TProdutoDAL }

procedure TProdutoDAL.LoadPesquisaProdutos(Target: TBufDataset);
var
  q: TSQLQuery;
begin
  q := Self.CreateSQLQuery;
  q.SQL.Text := 'select * from produto';
  q.Open;

  Target.CopyFromDataset(q);
  Target.First;

  q.Close;
  q.Free;
end;

end.

