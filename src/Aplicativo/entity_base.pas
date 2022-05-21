unit entity_base;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, TypInfo, Variants;

type
  { TEntityBase }

  TEntityBase = class
    private
      FId: LongInt;
      FDataCriacao: TDateTime;
      FDataAtualizacao: TDateTime;
      FDataExclusao: TDateTime;
      FIdUserCriacao: LongInt;
      FIdUserAtualizacao: LongInt;
      FIdUserExclusao: LongInt;
    public
      function AsString: string;
    published
      property Id: LongInt read FId write FId;
      // propriedade alimnetada automaticamente em TDALBase
      property DataCriacao: TDateTime read FDataCriacao write FDataCriacao;
      // propriedade alimnetada automaticamente em TDALBase
      property DataAtualizacao: TDateTime read FDataAtualizacao write FDataAtualizacao;
      // propriedade alimnetada automaticamente em TDALBase
      property DataExclusao: TDateTime read FDataExclusao write FDataExclusao;
      // propriedade alimnetada automaticamente em TDALBase
      property IdUserCriacao: LongInt read FIdUserCriacao write FIdUserCriacao;
      // propriedade alimnetada automaticamente em TDALBase
      property IdUserAtualizacao: LongInt read FIdUserAtualizacao write FIdUserAtualizacao;
      // propriedade alimnetada automaticamente em TDALBase
      property IdUserExclusao: LongInt read FIdUserExclusao write FIdUserExclusao;

  end;

implementation

{ TEntityBase }

function TEntityBase.AsString: string;
var
  i: Integer;
  vpTypeInfo: PTypeInfo;
  vPTypeData: PTypeData;
  vPPropList: PPropList;
begin

  vpTypeInfo := PTypeInfo(Self.ClassType.ClassInfo);
  vPTypeData := GetTypeData(vpTypeInfo);

  GetPropList(Self, vPPropList);

  Result := '';
  for i := 0 to vPTypeData^.PropCount -1 do
  begin
    Result := Result + vPPropList^[i]^.Name + ': ';
    Result := Result + vPPropList^[i]^.PropType^.Name + ' -> ';
    Result := Result + VarToStr(GetPropValue(Self, vPPropList^[i])) + LineEnding;
  end;
end;

end.

