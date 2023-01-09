unit usuario_filter;

{$mode ObjFPC}{$H+}

interface

uses
  validatable;

type

  { TUsuarioFilter }

  TUsuarioFilter = class(TValidatable)
  private
    FSituacao: string;
    FNome: string;
  published
    property Nome: string read FNome write FNome;
    property Situacao: string read FSituacao write FSituacao;
  end;

implementation

end.

