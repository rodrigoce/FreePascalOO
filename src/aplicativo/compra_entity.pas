unit compra_entity;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, entity_base, mini_orm;

type

  { TCompraEntity }

  TCompraEntity = class(TEntityBase)
    private
      FData: TDateTime;
      FIdFornecedor: Integer;
      FPerDescontos: Double;
      FTotalCompra: Double;
      FTotalDescontos: Double;
      FTotalProdutos: Double;
    public
      class procedure Map;
    published
      property Data: TDateTime read FData write FData;
      property IdFornecedor: Integer read FIdFornecedor write FIdFornecedor;
      property TotalProdutos: Double read FTotalProdutos write FTotalProdutos;
      property TotalCompra: Double read FTotalCompra write FTotalCompra;
      property TotalDescontos: Double read FTotalDescontos write FTotalDescontos;
      property PerDescontos: Double read FPerDescontos write FPerDescontos;

  end;


implementation

{ TCompraEntity }

class procedure TCompraEntity.Map;
begin
  TORMMapBuilder.Create.MapModel(TCompraEntity, 'COMPRA')
    .MapInt32PK('ID', 'Id')
    .MapString('SITUACAO', 'Situacao', 4, False)
    .MapInt32('NRO_REVISAO', 'NroRevisao', False)
    .MapDateTime('DATA', 'Data', False)
    .MapInt32('ID_FORNECEDOR', 'IdFornecedor', False)
    .MapDecimal('TOTAL_COMPRA', 'TotalCompra', 10, 2)
    .MapDecimal('TOTAL_PRODUTOS', 'TotalProdutos', 10, 2)
    .MapDecimal('TOTAL_DESCONTOS', 'TotalDescontos', 10, 2)
    .MapDecimal('PER_DESCONTOS', 'PerDescontos', 10, 2);
end;

end.

