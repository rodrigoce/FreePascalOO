unit produto_filter_validator;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, validator_base, produto_filter;

type

  { TProdutoFilterValidator }

  TProdutoFilterValidator = class(specialize TValidatorBase<TProdutoFilter>)
    public
      function Validate: Boolean;
  end;

implementation

{ TProdutoFilterValidator }

function TProdutoFilterValidator.Validate: Boolean;
begin
  Instance.ClearErrorMessages;

  // ainda não há validações
  Result := Instance.IsValid;
end;

end.

