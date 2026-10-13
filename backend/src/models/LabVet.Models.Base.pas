unit LabVet.Models.Base;

interface

type
  TInteiro64Opcional = record
    PossuiValor: Boolean;
    Valor: Int64;
  end;

  TMoedaOpcional = record
    PossuiValor: Boolean;
    Valor: Currency;
  end;

  TNumeroOpcional = record
    PossuiValor: Boolean;
    Valor: Extended;
  end;

  TTextoOpcional = record
    PossuiValor: Boolean;
    Valor: string;
  end;

  TEntidadeAuditavel = class
  public
    IdUsuarioInclusao: TInteiro64Opcional;
    IdUsuarioAlteracao: TInteiro64Opcional;
    DhInclusao: TDateTime;
    DhAlteracao: TDateTime;
    StAtivo: Boolean;
    constructor Create;
  end;

implementation

constructor TEntidadeAuditavel.Create;
begin
  inherited Create;
  StAtivo := True;
end;

end.
