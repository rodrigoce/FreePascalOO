unit tests_form;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  BBarPanel;

type

  { TTestesForm }

  TTestesForm = class(TForm)
    barAcoes: TBBarPanel;
    Button1: TButton;
    FlowPanel1: TFlowPanel;
    leftFlowPanel: TFlowPanel;
    rightFlowPanel: TFlowPanel;
  private

  public

  end;

var
  TestesForm: TTestesForm;

implementation

{$R *.lfm}

end.

