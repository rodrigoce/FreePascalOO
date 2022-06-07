unit validator_base;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, validatable, TypInfo;

type

  { TValidatorBase }

  generic TValidatorBase<T: TValidatable> = class
    private
      FInstance: T;
    public
      // é maior que
      function IsGreaterThan(ClassFieldName: string; Value: Double; Msg: string): Boolean;
      // é maior ou igual a
      function IsGreaterThanOrEquals(ClassFieldName: string; Value: Double; Msg: string): Boolean;
      // é menor que
      function IsLesserThan(ClassFieldName: string; Value: Double; Msg: string): Boolean;
      // é menor que
      function IsLesserThanOrEquals(ClassFieldName: string; Value: Double; Msg: string): Boolean;

      /////
      constructor Create(Instance: T);
  end;

implementation

{ TValidatorBase }

function TValidatorBase.IsGreaterThan(ClassFieldName: string; Value: Double;
  Msg: string): Boolean;
begin
  if GetPropValue(FInstance, ClassFieldName) > Value then
  begin
    FInstance.AddErrorValidationMsg(ClassFieldName, Msg);
    Result := False;
  end
  else
    Result := True;
end;

function TValidatorBase.IsGreaterThanOrEquals(ClassFieldName: string;
  Value: Double; Msg: string): Boolean;
begin
  if GetPropValue(FInstance, ClassFieldName) >= Value then
  begin
    FInstance.AddErrorValidationMsg(ClassFieldName, Msg);
    Result := False;
  end
  else
    Result := True;
end;

function TValidatorBase.IsLesserThan(ClassFieldName: string; Value: Double;
  Msg: string): Boolean;
begin
  if GetPropValue(FInstance, ClassFieldName) < Value then
  begin
    FInstance.AddErrorValidationMsg(ClassFieldName, Msg);
    Result := False;
  end
  else
    Result := True;
end;

function TValidatorBase.IsLesserThanOrEquals(ClassFieldName: string;
  Value: Double; Msg: string): Boolean;
begin
  if GetPropValue(FInstance, ClassFieldName) <= Value then
  begin
    FInstance.AddErrorValidationMsg(ClassFieldName, Msg);
    Result := False;
  end
  else
    Result := True;
end;

constructor TValidatorBase.Create(Instance: T);
begin
  inherited Create;
  FInstance := Instance;
end;

end.

