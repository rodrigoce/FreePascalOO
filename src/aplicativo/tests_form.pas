unit tests_form;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, Forms, Controls, StdCtrls,
  db_tests;

type

  { TTestesForm }

  TTestesForm = class(TForm)
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private

  public
    class procedure Open;
  end;

var
  TestesForm: TTestesForm;

implementation

{$R *.lfm}

{ TTestesForm }

procedure TTestesForm.Button1Click(Sender: TObject);
var
  t: TDBTests;
begin
  t := TDBTests.Create;
  t.RegisterTests;
  t.Execute;
  t.Free;
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

