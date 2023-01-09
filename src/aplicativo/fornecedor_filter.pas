unit fornecedor_filter;

{$mode ObjFPC}{$H+}

interface

uses
  validatable;

type

  { TFornecedorFilter }

  TFornecedorFilter = class(TValidatable)
  private
    FContato: string;
    FSituacao: string;
    FNome: string;
  published
    property Nome: string read FNome write FNome;
    property Situacao: string read FSituacao write FSituacao;
    property Contato: string read FContato write FContato;
  end;

implementation

end.

