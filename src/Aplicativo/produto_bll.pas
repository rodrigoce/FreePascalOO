unit produto_bll;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, produto_entity, produto_dal, produto_validator,
  application_types, BufDataset;

type

  { TProdutoBLL }

  TProdutoBLL = class
    private
      FProdutoDAL: TProdutoDAL;
    public
      function NewProduto: TProdutoEntity;
      function InsertProduto(Produto: TProdutoEntity): TOperationResult;
      function UpdateProduto(Produto: TProdutoEntity): TOperationResult;
      function FindProdutoByPK(Id: Integer): TProdutoEntity;
      procedure SearchProdutos(Target: TBufDataset);
      function Validate(Produto: TProdutoEntity; IsInsert: Boolean): Boolean;
      constructor Create;
      destructor Destroy; override;

  end;

implementation

{ TProdutoBLL }

function TProdutoBLL.NewProduto: TProdutoEntity;
var
  produto: TProdutoEntity;
begin
  produto := TProdutoEntity.Create;

  // valores iniciais, etc.
  //produto.Nome := '...';
  Result := produto;
end;

function TProdutoBLL.InsertProduto(Produto: TProdutoEntity): TOperationResult;
var
  opResult: TOperationResult;
begin
  if Validate(Produto, True) then
  begin
    Produto.Id := FProdutoDAL.GetNextSequence;
    FProdutoDAL.Insert(Produto);
    opResult.Success := True;
    opResult.Message := 'Produto inserido com sucesso.';
  end
  else
  begin
    opResult.Success := False;
    opResult.Message := 'Erro ao validar dados.';
  end;
  Result := opResult;
end;

function TProdutoBLL.UpdateProduto(Produto: TProdutoEntity): TOperationResult;
var
  opResult: TOperationResult;
begin
  if Validate(Produto, False) then
  begin
    FProdutoDAL.Update(Produto);
    opResult.Success := True;
    opResult.Message := 'Produto atualizado com sucesso.';
  end
  else
  begin
    opResult.Success := False;
    opResult.Message := 'Erro ao validar dados.';
  end;
  Result := opResult;
end;

function TProdutoBLL.FindProdutoByPK(Id: Integer): TProdutoEntity;
begin
  Result := FProdutoDAL.FindByPK(Id);
end;

procedure TProdutoBLL.SearchProdutos(Target: TBufDataset);
begin
  FProdutoDAL.SearchProdutos(Target);
end;

function TProdutoBLL.Validate(Produto: TProdutoEntity; IsInsert: Boolean
  ): Boolean;
var
  produtoValidator: TProdutoValidator;
begin
  produtoValidator := TProdutoValidator.Create(Produto);
  Result := produtoValidator.Validate(IsInsert);
  produtoValidator.Free;
end;

constructor TProdutoBLL.Create;
begin
  FProdutoDAL := TProdutoDal.Create;
end;

destructor TProdutoBLL.Destroy;
begin
 FProdutoDAL.Free;
 inherited;
end;



end.

