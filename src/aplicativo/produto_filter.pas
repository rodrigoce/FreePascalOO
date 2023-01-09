unit produto_filter;

{$mode ObjFPC}{$H+}

interface

uses
  validatable;

type

  { TProdutoFilter }

  TProdutoFilter = class(TValidatable)
  private
    FSituacao: string;
    FCodigo: string;
    FNome: string;
  published
    property Codigo: string read FCodigo write FCodigo;
    property Nome: string read FNome write FNome;
    property Situacao: string read FSituacao write FSituacao;
  end;

implementation

end.

