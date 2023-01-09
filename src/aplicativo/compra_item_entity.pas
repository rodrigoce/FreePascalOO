unit compra_item_entity;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, entity_base, mini_orm;

type

  { TCompraItemEntity }

  TCompraItemEntity = class(TEntityBase)
    private
      FIdCompra: Integer;
      FIdProduto: Integer;
      FQtde: Double;
      FTotal: Double;
      FValor: Double;
    public
      class procedure Map;
    published
      property IdCompra: Integer read FIdCompra write FIdCompra;
      property IdProduto: Integer read FIdProduto write FIdProduto;
      property Qtde: Double read FQtde write FQtde;
      property Valor: Double read FValor write FValor;
      property Total: Double read FTotal write FTotal;
  end;


implementation

{ TCompraItemEntity }

class procedure TCompraItemEntity.Map;
begin
  TORMMapBuilder.Create.MapModel(TCompraItemEntity, 'COMPRA_ITEM')
    .MapInt32PK('ID', 'Id')
    .MapString('SITUACAO', 'Situacao', 1)
    .MapInt32('NRO_REVISAO', 'NroRevisao', False)
    .MapInt32('ID_COMPRA', 'IdCompra', False)
    .MapInt32('ID_PRODUTO', 'IdProduto', False)
    .MapDecimal('QTDE', 'Qtde', 10, 2)
    .MapDecimal('VALOR', 'Valor', 10, 2)
    .MapDecimal('TOTAL', 'Total', 10, 2);
end;

end.
