{ This file was automatically created by Lazarus. Do not edit!
  This source is only used to compile and install the package.
 }

unit Comps;

{$warn 5023 off : no warning about unused units}
interface

uses
  ComboBoxValue, LinkLabel, PanelX, LazarusPackageIntf;

implementation

procedure Register;
begin
  RegisterUnit('ComboBoxValue', @ComboBoxValue.Register);
  RegisterUnit('LinkLabel', @LinkLabel.Register);
  RegisterUnit('PanelX', @PanelX.Register);
end;

initialization
  RegisterPackage('Comps', @Register);
end.
