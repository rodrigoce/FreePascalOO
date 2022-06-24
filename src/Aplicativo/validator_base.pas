unit validator_base;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, validatable, TypInfo, LazUTF8;

type

  { TValidatorBase }

  // Testa se a propriedade de um objeto tem valores não desejados e atribui
  // uma mensagem de validação.
  generic TValidatorBase<T: TValidatable> = class
    private
      FInstance: T;
    public
      constructor Create(Instance: T);
      ///////////////////////////////
      // é maior que
      function IsGreaterThan(ClassPropName: string; Value: Double; Msg: string): Boolean;
      // é maior ou igual a
      function IsGreaterThanOrEquals(ClassPropName: string; Value: Double; Msg: string): Boolean;
      // é menor que
      function IsLesserThan(ClassPropName: string; Value: Double; Msg: string): Boolean;
      // é menor que
      function IsLessThanOrEquals(ClassPropName: string; Value: Double; Msg: string): Boolean;
      // a string está vazia
      function IsEmpty(ClassPropName: string; Msg: string): Boolean;
      // a string é menor que
      function LengthIsLessThan(ClassPropName: string; Value: Integer; Msg: string): Boolean;
      // a string é menor ou igual a
      function LengthIsLessThanOrEquals(ClassPropName: string; Value: Integer; Msg: string): Boolean;

      property Instance: T read FInstance write FInstance;
  end;

implementation

{ TValidatorBase }

function TValidatorBase.IsGreaterThan(ClassPropName: string; Value: Double;
  Msg: string): Boolean;
begin
  if GetPropValue(FInstance, ClassPropName) > Value then
  begin
    FInstance.AddErrorValidationMsg(ClassPropName, Msg);
    Result := False;
  end
  else
    Result := True;
end;

function TValidatorBase.IsGreaterThanOrEquals(ClassPropName: string;
  Value: Double; Msg: string): Boolean;
begin
  if GetPropValue(FInstance, ClassPropName) >= Value then
  begin
    FInstance.AddErrorValidationMsg(ClassPropName, Msg);
    Result := False;
  end
  else
    Result := True;
end;

function TValidatorBase.IsLesserThan(ClassPropName: string; Value: Double;
  Msg: string): Boolean;
begin
  if GetPropValue(FInstance, ClassPropName) < Value then
  begin
    FInstance.AddErrorValidationMsg(ClassPropName, Msg);
    Result := False;
  end
  else
    Result := True;
end;

function TValidatorBase.IsLessThanOrEquals(ClassPropName: string;
  Value: Double; Msg: string): Boolean;
begin
  if GetPropValue(FInstance, ClassPropName) <= Value then
  begin
    FInstance.AddErrorValidationMsg(ClassPropName, Msg);
    Result := False;
  end
  else
    Result := True;
end;

function TValidatorBase.IsEmpty(ClassPropName: string;
  Msg: string): Boolean;
begin
  if UTF8Length(UTF8Trim(GetPropValue(FInstance, ClassPropName))) = 0 then
  begin
    FInstance.AddErrorValidationMsg(ClassPropName, Msg);
    Result := False;
  end
  else
    Result := True;
end;

function TValidatorBase.LengthIsLessThan(ClassPropName: string; Value: Integer;
  Msg: string): Boolean;
begin
  if UTF8Length(UTF8Trim(GetPropValue(FInstance, ClassPropName))) < Value then
  begin
    FInstance.AddErrorValidationMsg(ClassPropName, Msg);
    Result := False;
  end
  else
    Result := True;
end;

function TValidatorBase.LengthIsLessThanOrEquals(ClassPropName: string;
  Value: Integer; Msg: string): Boolean;
begin
  if UTF8Length(UTF8Trim(GetPropValue(FInstance, ClassPropName))) <= Value then
  begin
    FInstance.AddErrorValidationMsg(ClassPropName, Msg);
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

