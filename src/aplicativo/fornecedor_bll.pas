unit fornecedor_bll;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, BufDataset, fornecedor_entity, fornecedor_dal,
  fornecedor_validator, application_types, fornecedor_filter,
  fornecedor_filter_validator, db_context, bll_base;

type

  { TFornecedorBLL }

  TFornecedorBLL = class(TBllBase)
    private
      FFornecedorDAL: TFornecedorDAL;
    public
      function NewFornecedor: TFornecedorEntity;
      procedure FillDefaultFilter(filter: TFornecedorFilter);
      function AddOrUpdateFornecedor(Fornecedor: TFornecedorEntity): TOperationResult;
      function SearchFornecedores(Buffer: TBufDataset; Filter: TFornecedorFilter): TOperationResult;
      constructor Create(ADbContext: TDbContext); override;
      destructor Destroy; override;
      //
      property InnerDAL: TFornecedorDAL read FFornecedorDAL;

  end;

implementation

{ TFornecedorBLL }

function TFornecedorBLL.NewFornecedor: TFornecedorEntity;
var
  fornecedor: TFornecedorEntity;
begin
  fornecedor := TFornecedorEntity.Create;

  // valores iniciais, etc.
  fornecedor.Situacao := 'A';
  Result := fornecedor;
end;

procedure TFornecedorBLL.FillDefaultFilter(filter: TFornecedorFilter);
begin
  filter.Situacao := 'A';
end;

function TFornecedorBLL.AddOrUpdateFornecedor(Fornecedor: TFornecedorEntity): TOperationResult;
var
  opResult: TOperationResult;
  IsInsert: Boolean;
  fornecedorValidator: TFornecedorValidator;
begin
  IsInsert := Fornecedor.Id = 0;

  fornecedorValidator := TFornecedorValidator.Create(Fornecedor);

  if fornecedorValidator.Validate(IsInsert, DbContext) then
  begin
    try
      DbContext.BeginTransaction;
      if IsInsert then
      begin
        Fornecedor.Id := FFornecedorDAL.GetNextSequence;
        FFornecedorDAL.Insert(Fornecedor);
      end
      else
      begin
        FFornecedorDAL.Update(Fornecedor);
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

  fornecedorValidator.Free;
end;

function TFornecedorBLL.SearchFornecedores(Buffer: TBufDataset; Filter: TFornecedorFilter
  ): TOperationResult;
var
  opResult: TOperationResult;
  fornecedorFilterValidator: TFornecedorFilterValidator;
begin
  fornecedorFilterValidator := TFornecedorFilterValidator.Create(Filter);

  if fornecedorFilterValidator.Validate then
  begin
    FFornecedorDAL.SearchFornecedores(Buffer, Filter);
    opResult.Success := True;
  end
  else
  begin
    opResult.Message := 'Erro ao validar dados.';
    opResult.Success := False;
  end;

  fornecedorFilterValidator.Free;

  Result := opResult;
end;

constructor TFornecedorBLL.Create(ADbContext: TDbContext);
begin
  inherited Create(ADbContext);
  FFornecedorDAL := TFornecedorDal.Create(ADbContext);
end;

destructor TFornecedorBLL.Destroy;
begin
  FFornecedorDAL.Free;
  inherited;
end;



end.

