unit produto_filter;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, validatable;

type

  { TProdutoFilter }

  TProdutoFilter = class(TValidatable)
  private
    FCodigo: string;
    FNome: string;
  published
    property Codigo: string read FCodigo write FCodigo;
    property Nome: string read FNome write FNome;
  end;

implementation

end.

