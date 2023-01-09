unit produto_bll;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, BufDataset, produto_entity, produto_dal, produto_validator,
  application_types, produto_filter, produto_filter_validator, db_context,
  bll_base;

type

  { TProdutoBLL }

  TProdutoBLL = class(TBllBase)
    private
      FProdutoDAL: TProdutoDAL;
    public
      function NewProduto: TProdutoEntity;
      procedure FillDefaultFilter(filter: TProdutoFilter);
      function AddOrUpdateProduto(Produto: TProdutoEntity): TOperationResult;
      function SearchProdutos(Buffer: TBufDataset; Filter: TProdutoFilter): TOperationResult;
      constructor Create(ADbContext: TDbContext); override;
      destructor Destroy; override;
      //
      property InnerDAL: TProdutoDAL read FProdutoDAL;
  end;

implementation

{ TProdutoBLL }

function TProdutoBLL.NewProduto: TProdutoEntity;
var
  produto: TProdutoEntity;
begin
  produto := TProdutoEntity.Create;

  // valores iniciais, etc.
  produto.Situacao := 'A';
  Result := produto;
end;

procedure TProdutoBLL.FillDefaultFilter(filter: TProdutoFilter);
begin
  filter.Situacao := 'A';
end;

function TProdutoBLL.AddOrUpdateProduto(Produto: TProdutoEntity): TOperationResult;
var
  opResult: TOperationResult;
  IsInsert: Boolean;
  produtoValidator: TProdutoValidator;
begin
  IsInsert := Produto.Id = 0;

  produtoValidator := TProdutoValidator.Create(Produto);

  if produtoValidator.Validate(IsInsert, DbContext) then
  begin
    try
      DbContext.BeginTransaction;
      if IsInsert then
      begin
        Produto.Id := FProdutoDAL.GetNextSequence;
        FProdutoDAL.Insert(Produto);
      end
      else
      begin
        FProdutoDAL.Update(Produto);
      end;
      DbContext.CommitTransaction;
      opResult.Success := True;
    except
      on Ex: Exception do
      begin
        DbContext.RollbackTransaction;
        opResult.Success := False;
        opResult.Message := Ex.Message;
      end;
    end;
  end
  else
  begin
    opResult.Success := False;
    opResult.Message := 'Erro ao validar dados.';
  end;
  Result := opResult;

  produtoValidator.Free;
end;

function TProdutoBLL.SearchProdutos(Buffer: TBufDataset; Filter: TProdutoFilter
  ): TOperationResult;
var
  opResult: TOperationResult;
  produtoFilterValidator: TProdutoFilterValidator;
begin
  produtoFilterValidator := TProdutoFilterValidator.Create(Filter);

  if produtoFilterValidator.Validate then
  begin
    FProdutoDAL.SearchProdutos(Buffer, Filter);
    opResult.Success := True;
  end
  else
  begin
    opResult.Message := 'Erro ao validar dados.';
    opResult.Success := False;
  end;

  produtoFilterValidator.Free;

  Result := opResult;
end;

constructor TProdutoBLL.Create(ADbContext: TDbContext);
begin
  inherited Create(ADbContext);
  FProdutoDAL := TProdutoDal.Create(ADbContext);
end;

destructor TProdutoBLL.Destroy;
begin
  FProdutoDAL.Free;
  inherited;
end;



end.

