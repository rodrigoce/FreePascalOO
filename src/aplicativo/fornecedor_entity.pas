unit fornecedor_entity;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, entity_base, mini_orm, application_functions, Dialogs;

type

  { TFornecedorEntity }

  TFornecedorEntity = class(TEntityBase)
    private
      FContatos: string;
      FContatosPP: string;
      FNome: string;
      FNomePP: string;
      procedure SetContatos(AValue: string);
      procedure SetNome(Value: string);
    public
      class procedure Map;
    published
      property Nome: string read FNome write SetNome;
      property NomePP: string read FNomePP;
      property Contatos: string read FContatos write SetContatos;
      property ContatosPP: string read FContatosPP write FContatosPP;
  end;


implementation


{ TFornecedorEntity }

procedure TFornecedorEntity.SetNome(Value: string);
begin
  FNome := Value;
  FNomePP := PPConvert(Value);
end;

procedure TFornecedorEntity.SetContatos(AValue: string);
begin
  FContatos := AValue;
  FContatosPP := PPConvert(AValue);
end;

class procedure TFornecedorEntity.Map;
begin
  TORMMapBuilder.Create.MapModel(TFornecedorEntity, 'FORNECEDOR')
    .MapInt32PK('ID', 'Id')
    .MapString('SITUACAO', 'Situacao', 1)
    .MapInt32('NRO_REVISAO', 'NroRevisao', False)
    .MapString('NOME', 'Nome', 60)
    .MapString('NOME_PP', 'NomePP', 60)
    .MapString('CONTATOS', 'Contatos', 500)
    .MapString('CONTATOS_PP', 'ContatosPP', 500);
end;

end.

