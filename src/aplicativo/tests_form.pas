unit tests_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  colors_functions, PanelTitle, LCLIntf;

type

  { TTestesForm }

  TTestesForm = class(TForm)
    edH: TEdit;
    edS: TEdit;
    edV: TEdit;
    edR: TEdit;
    edG: TEdit;
    edB: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Shape1: TShape;
    procedure edHChange(Sender: TObject);
    procedure edHExit(Sender: TObject);
    procedure edRExit(Sender: TObject);
  private

  public
    class procedure Open;
  end;

var
  TestesForm: TTestesForm;

implementation

{$R *.lfm}

{ TTestesForm }

procedure TTestesForm.edRExit(Sender: TObject);
var
  r, g, b: Integer;
  h, s, v: Double;
begin
  r := StrToInt(edR.Text);
  g := StrToInt(edG.Text);
  b := StrToInt(edB.Text);
  Shape1.Brush.Color := RGB(r, g, b);
  RGBToHSV(r, g, b, h, s, v);
  edH.Text := h.ToString;
  edS.Text := s.ToString;
  edV.Text := v.ToString;
end;

procedure TTestesForm.edHExit(Sender: TObject);
var
  r, g, b: Integer;
  h, s, v: Single;
begin
  h := StrToFloat(edH.Text);
  s := StrToFloat(edS.Text);
  v := StrToFloat(edV.Text);
  HSVToRGB(h, s, v, r, g, b);
  if (s + 0.25) > 1 then
    s := s - 0.25
  else
    s := s + 0.25;
  HSVToRGB(h, s, v, r, g, b);
  Shape1.Pen.Color := RGB(r, g, b);
end;

procedure TTestesForm.edHChange(Sender: TObject);
begin

end;

class procedure TTestesForm.Open;
begin
  Application.CreateForm(TTestesForm, TestesForm);
  with TestesForm do
  begin
    ShowModal;
  end;
end;

end.

