unit usuario_filter_validator;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, validator_base, usuario_filter;

type

  { TUsuarioFilterValidator }

  TUsuarioFilterValidator = class(specialize TValidatorBase<TUsuarioFilter>)
    public
      function Validate: Boolean;
  end;

implementation

{ TUsuarioFilterValidator }

function TUsuarioFilterValidator.Validate: Boolean;
begin
  Instance.ClearErrorMessages;

  // ainda não há validações
  Result := Instance.IsValid;
end;

end.

