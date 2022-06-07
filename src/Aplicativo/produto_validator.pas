unit produto_validator;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, validator_base, produto_entity;

type

  { TProdutoValidator }

  TProdutoValidator = class(specialize TValidatorBase<TProdutoEntity>)
    public
      function Validate: Boolean;

  end;

implementation

{ TProdutoValidator }

function TProdutoValidator.Validate: Boolean;
begin
  Result := IsLesserThan('PrecoVenda', 0.01, 'O Preço de Venda deve ser pelo menos 0,01');
end;

end.

