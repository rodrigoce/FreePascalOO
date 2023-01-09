unit compra_filter_validator;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, validator_base, compra_filter;

type

  { TCompraFilterValidator }

  TCompraFilterValidator = class(specialize TValidatorBase<TCompraFilter>)
    public
      function Validate: Boolean;
  end;

implementation

{ TCompraFilterValidator }

function TCompraFilterValidator.Validate: Boolean;
begin
  Instance.ClearErrorMessages;

  // ainda não há validações
  Result := Instance.IsValid;
end;

end.

