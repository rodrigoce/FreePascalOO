unit application_types;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type
  TOperationResult = record
    Success: Boolean;
    Message: string;
  end;

  TValidationMsgItem = class
  private
    FClassFieldName: string;
    FMsgList: TStringList;
  public
    property ClassPropName: string read FClassFieldName write FClassFieldName;
    property MsgList: TStringList read FMsgList write FMsgList;
  end;

implementation

end.

