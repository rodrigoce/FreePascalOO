unit fornecedor_filter_validator;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, validator_base, fornecedor_filter;

type

  { TFornecedorFilterValidator }

  TFornecedorFilterValidator = class(specialize TValidatorBase<TFornecedorFilter>)
    public
      function Validate: Boolean;
  end;

implementation

{ TFornecedorFilterValidator }

function TFornecedorFilterValidator.Validate: Boolean;
begin
  Instance.ClearErrorMessages;

  // ainda não há validações
  Result := Instance.IsValid;
end;

end.

