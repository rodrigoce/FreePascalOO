unit tests_form;

{$mode ObjFPC}{$H+}

interface

uses
  SysUtils, Forms, Controls, StdCtrls, DBGrids, Generics.Collections, db_tests,
  fields_builder, grid_configurator, test_base, db_context,
  application_functions, BufDataset, DB, SQLDB, Classes, Dialogs, Math;

type

  { TTestesForm }

  TTestesForm = class(TForm)
    bufTests: TBufDataset;
    btRunTests: TButton;
    gridTests: TDBGrid;
    dsTests: TDataSource;
    procedure btRunTestsClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    FDBTests: TDBTests;
    procedure ConfigureGrid;
    procedure RegisterTests;
    procedure AfterExecuteItem(const TestNumber: Integer; const TestResult: TTestResult);
  public
    class procedure Open;
  end;

var
  TestesForm: TTestesForm;

implementation

{$R *.lfm}

{ TTestesForm }

procedure TTestesForm.btRunTestsClick(Sender: TObject);
begin
  FDBTests.Execute;
end;

procedure TTestesForm.Button1Click(Sender: TObject);
begin

end;

{procedure TTestesForm.ToggleBox1Change(Sender: TObject);
var q: tsqlquery;
  i: integer;
begin
  q := gAppDbContext.CreateSQLQuery;
  q.SQL.Text := 'select * from test';
  q.Open;
  for i := 0 to q.Fields.Count -1 do
  begin
    if q.Fields[i].IsNull then
      ShowMessage(q.Fields[i].FieldName);
  end;

  if q.FieldByName('INT_32_NULL_IF_ZERO').IsNull THEN
    ShowMessage(q.FieldByName('INT_32_NULL_IF_ZERO').FieldName);
end;}

procedure TTestesForm.ConfigureGrid;
var
  fb: TFieldsBuilder;
  gc: TGridConfigurator;
begin
  fb := TFieldsBuilder.Create(bufTests);
  bufTests.Fields.Clear;
  fb.AddLongIntField('TestNumber');
  fb.AddStringField('Title', 1000);
  fb.AddStringField('Pass', 20);
  bufTests.CreateDataset;
  fb.Free;

  gc := TGridConfigurator.Create;
  gc.WithGrid(gridTests)
    .AddOrderAbility
    .SetDefaultProps
    .AddColumn('TestNumber', 'Número', 80)
    .AddColumn('Title', 'Titulo', 700)
    .AddColumn('Pass', 'Passou?', 120);
  gc.Free;
end;

procedure TTestesForm.RegisterTests;
var
  lisfOfTests: specialize TList<TTestItem>;
  itemOfTest: TTestItem;
begin
  FDBTests.RegisterTests;
  FDBTests.TestItemAfterExecute := @AfterExecuteItem;
  lisfOfTests := FDBTests.GetTestList;

  bufTests.Close;
  bufTests.CreateDataset;
  for itemOfTest in lisfOfTests do
  begin
    bufTests.Append;
    bufTests.FieldByName('TestNumber').Value := itemOfTest.TestNumber;
    bufTests.FieldByName('Title').Value := itemOfTest.Title;
    bufTests.FieldByName('Pass').Value := 'NÃO EXECUTADO';
    bufTests.Post;
  end;

  bufTests.First;
end;

procedure TTestesForm.AfterExecuteItem(const TestNumber: Integer;
  const TestResult: TTestResult);
begin
  bufTests.Locate('TestNumber', TestNumber, []);
  bufTests.Edit;
  if TestResult.Pass = tpsPass then
    bufTests.FieldByName('Pass').Value := 'SIM'
  else if TestResult.Pass = tpsFail then
    bufTests.FieldByName('Pass').Value := 'NÃO'
  else
     bufTests.FieldByName('Pass').Value := 'NÃO EXECUTADO';
  bufTests.Post;
end;

class procedure TTestesForm.Open;
begin
  Application.CreateForm(TTestesForm, TestesForm);
  with TestesForm do
  begin
    ConfigureGrid;
    FDBTests := TDBTests.Create(0);
    RegisterTests;

    ShowModal;

    FDBTests.Free;
  end;
end;

end.

