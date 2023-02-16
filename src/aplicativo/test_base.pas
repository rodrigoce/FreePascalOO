unit test_base;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Controls,
  LCLIntf, Generics.Collections;

type

  TTestPassStatus = (tpsNotExecuted, tpsFail, tpsPass);

  TTestResult = record
    Pass: TTestPassStatus;
    Message: string;
  end;

  TTestMethodDelegate = function: TTestResult of object;
  TTestItemAfterExecute = procedure(const TestNumber: Integer; const TestResult: TTestResult) of object;

  { TTestItem }

  TTestItem = class
  private
    FTestMethod: TTestMethodDelegate;
    FTestNumber: Integer;
    FTestResult: TTestResult;
    FTitle: string;
  public
    property TestNumber: Integer read FTestNumber write FTestNumber;
    property TestMethod: TTestMethodDelegate read FTestMethod write FTestMethod;
    property Title: string read FTitle write FTitle;
    property TestResult: TTestResult read FTestResult write FTestResult;
  end;

  { TTestsBase }

  TTestsBase = class
  private
    FInitialTestNumber: Integer;
    FStopTests: Boolean;
    FTestItemAfterExecute: TTestItemAfterExecute;
  protected
    FTestItemList: specialize TList<TTestItem>;
    procedure AddTestItem(ATestMethod: TTestMethodDelegate; ATitle: string);

    procedure IsGreaterThan(Value, Reference: Integer; var TestResult: TTestResult);
    procedure IsEquals(Value1, Value2: string; var TestResult: TTestResult);
  public
    constructor Create(InitialTestNumber: Integer);
    destructor Destroy; override;

    procedure RegisterTests; virtual; abstract;
    procedure Execute;
    function GetTestList: specialize TList<TTestItem>;
    property TestItemAfterExecute: TTestItemAfterExecute read FTestItemAfterExecute write FTestItemAfterExecute;
    property StopTests: Boolean read FStopTests write FStopTests;
  end;

implementation

{ TTestsBase }

procedure TTestsBase.AddTestItem(ATestMethod: TTestMethodDelegate; ATitle: string);
var
  item: TTestItem;
begin
  item := TTestItem.Create;
  item.TestNumber := FTestItemList.Count + 1 + FInitialTestNumber;
  item.TestMethod := ATestMethod;
  item.Title := ATitle;
  FTestItemList.Add(item);
end;

procedure TTestsBase.IsGreaterThan(Value, Reference: Integer;
  var TestResult: TTestResult);
begin
  if Value > Reference then
    TestResult.Pass := tpsPass
  else
    TestResult.Pass := tpsFail
end;

procedure TTestsBase.IsEquals(Value1, Value2: string;
  var TestResult: TTestResult);
begin
  if Value1 = Value2 then
    TestResult.Pass := tpsPass
  else
    TestResult.Pass := tpsFail
end;

constructor TTestsBase.Create(InitialTestNumber: Integer);
begin
  FInitialTestNumber := InitialTestNumber;
  FTestItemList := specialize TList<TTestItem>.Create;
end;

destructor TTestsBase.Destroy;
var
  item: TTestItem;
begin
  for item in FTestItemList do
  begin
    item.Free;
  end;

  inherited;
end;

procedure TTestsBase.Execute;
var
  item: TTestItem;
  testResult: TTestResult;
begin
  StopTests := False;
  for item in FTestItemList do
  begin
    if StopTests then Break;
    try
      testResult := item.TestMethod();
    except
      on ex: Exception do
      begin
        testResult.Pass := tpsFail;
        testResult.Message := ex.Message;
      end;
    end;
    item.TestResult := testResult;
    try
      if TestItemAfterExecute <> nil then
        TestItemAfterExecute(item.TestNumber, item.TestResult);
    except
    end;
  end;
end;

function TTestsBase.GetTestList: specialize TList<TTestItem>;
begin
  Result := FTestItemList;
end;



end.

