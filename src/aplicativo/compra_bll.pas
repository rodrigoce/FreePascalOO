unit compra_bll;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, BufDataset, compra_entity, compra_dal, compra_validator,
  application_types, compra_filter, compra_filter_validator, compra_item_entity,
  compra_item_dal, db_context, bll_base,
  Generics.Collections, DB, Variants;

type

  { TCompraBLL }

  TCompraBLL = class(TBllBase)
    private
      FCompraDAL: TCompraDAL;
      FCompraItemDAL: TCompraItemDAL;
      function NewCompra: TCompraEntity;
      procedure AddOrUpdateItens(Compra: TCompraEntity; Itens: specialize TObjectList<TCompraItemEntity>);
    public
      procedure FillDefaultFilter(filter: TCompraFilter);
      procedure LoadCompra(Id: Integer; var Compra: TCompraEntity; var Itens: specialize TObjectList<TCompraItemEntity>);
      function AddOrUpdateCompra(Compra: TCompraEntity; Itens: specialize TObjectList<TCompraItemEntity>): TOperationResult;
      function SearchCompras(Buffer: TBufDataset; Filter: TCompraFilter): TOperationResult;
      function NewCompraItem: TCompraItemEntity;

      constructor Create(ADbContext: TDbContext); override;
      destructor Destroy; override;
      //
      property InnerDAL: TCompraDAL read FCompraDAL;
  end;

implementation

{ TCompraBLL }

function TCompraBLL.NewCompra: TCompraEntity;
var
  compra: TCompraEntity;
begin
  compra := TCompraEntity.Create;

  // valores iniciais, etc.
  compra.Situacao := 'A';
  Result := compra;
end;

procedure TCompraBLL.AddOrUpdateItens(Compra: TCompraEntity; Itens: specialize
  TObjectList<TCompraItemEntity>);
var
  IsInsertItem: Boolean;
  item: TCompraItemEntity;
begin
  for item in Itens do
  begin
    IsInsertItem := item.Id = 0;
    if IsInsertItem then
    begin
      item.Id := FCompraItemDAL.GetNextSequence;
      item.IdCompra := Compra.Id;
      FCompraItemDAL.Insert(item);
    end
    else
    begin
      FCompraItemDAL.Update(item);
    end;
  end;
end;


function TCompraBLL.NewCompraItem: TCompraItemEntity;
var
  compraItem: TCompraItemEntity;
begin
  compraItem := TCompraItemEntity.Create;

  // valores iniciais, etc.
  compraItem.Situacao := 'A';
  Result := compraItem;
end;

procedure TCompraBLL.FillDefaultFilter(filter: TCompraFilter);
begin
  filter.Situacao := 'A';
  filter.DataIni := Now;
  filter.DataFim := Now;
end;

function TCompraBLL.AddOrUpdateCompra(Compra: TCompraEntity; Itens: specialize
  TObjectList<TCompraItemEntity>): TOperationResult;
var
  opResult: TOperationResult;
  IsInsertCompra: Boolean;
  compraValidator: TCompraValidator;
begin
  IsInsertCompra := Compra.Id = 0;

  compraValidator := TCompraValidator.Create(Compra);

  if compraValidator.Validate(IsInsertCompra, Itens, DbContext) then
  begin
    try
      DbContext.BeginTransaction;
      if IsInsertCompra then
      begin
        Compra.Id := FCompraDAL.GetNextSequence;
        FCompraDAL.Insert(Compra);

        AddOrUpdateItens(Compra, Itens);
      end
      else
      begin
        FCompraDAL.Update(Compra);

        AddOrUpdateItens(Compra, Itens);
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

  compraValidator.Free;
end;

procedure TCompraBLL.LoadCompra(Id: Integer; var Compra: TCompraEntity;
  var Itens: specialize TObjectList<TCompraItemEntity>);
begin
  if Id = 0 then
  begin
    Compra := NewCompra;
    Itens := specialize TObjectList<TCompraItemEntity>.Create;
  end
  else
  begin
    Compra := InnerDAL.FindByPK(Id);
    Itens := FCompraItemDAL.FindByFilter(VarArrayOf(['IdCompra', '=', Id]));
  end;
end;

function TCompraBLL.SearchCompras(Buffer: TBufDataset; Filter: TCompraFilter
  ): TOperationResult;
var
  opResult: TOperationResult;
  compraFilterValidator: TCompraFilterValidator;
begin
  compraFilterValidator := TCompraFilterValidator.Create(Filter);

  if compraFilterValidator.Validate then
  begin
    FCompraDAL.SearchCompras(Buffer, Filter);
    opResult.Success := True;
  end
  else
  begin
    opResult.Message := 'Erro ao validar dados.';
    opResult.Success := False;
  end;

  compraFilterValidator.Free;

  Result := opResult;
end;

constructor TCompraBLL.Create(ADbContext: TDbContext);
begin
  inherited Create(ADbContext);
  FCompraDAL := TCompraDal.Create(ADbContext);
  FCompraItemDAL := TCompraItemDal.Create(ADbContext);
end;

destructor TCompraBLL.Destroy;
begin
  FCompraDAL.Free;
  FCompraItemDAL.Free;
  inherited;
end;



end.

