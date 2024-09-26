program MVPCliFMXApp;

uses
  System.StartUpCopy,
  FMX.Forms,
  ufmPrincipal in 'ufmPrincipal.pas' {frmPrincipal},
  udmPrincipal in 'udmPrincipal.pas' {dtmPrincipal: TDataModule},
  untCliente in 'untCliente.pas',
  untClientesController in 'untClientesController.pas',
  untUtils in 'untUtils.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TdtmPrincipal, dtmPrincipal);
  Application.Run;
end.
