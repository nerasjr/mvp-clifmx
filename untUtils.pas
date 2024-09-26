unit untUtils;

interface

uses
  System.SysUtils, FMX.Forms, FMX.Dialogs, System.UITypes, FMX.DialogService;

  procedure Confirma(AMsg: String; AOnConfirm: TProc<Boolean> = nil);

implementation

procedure Confirma(AMsg: String; AOnConfirm: TProc<Boolean>);
begin
  if AMsg.IsEmpty then
    AMsg := 'Confirma?';

  TDialogService.MessageDialog(AMsg, TMsgDlgType.mtConfirmation, [TMsgDlgBtn.mbYes, TMsgDlgBtn.mbNo], TMsgDlgBtn.mbNo, 0,
    procedure(const AResult: TModalResult)
    begin
      AOnConfirm(AResult = mrYes);
    end);
end;

end.

