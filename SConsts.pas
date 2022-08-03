unit SConsts;

interface

resourcestring
  sEmail = 'reports@vostok-td.ru';
  sEmailPassword = 'uaA2eAiRSo^2';
  sFromEmailAdress = 'Phoenix.Russia@cchellenic.com';

  // SQL requests
  SSQLAddHeadOrder = 'EXEC REPORTS..CocaCola_SFA_AddHeadOrder ''%s'', ''%s'', ''%s'', ''%s'', '  +
                                                              ' ''%s'', ''%s'', ''%s'', ''%s'', ' +
                                                              ' ''%s'', ''%s'', ''%s'', ''%s'', ' +
                                                              ' ''%s'' ';

  SSQLAddMoveOrder  = 'EXEC REPORTS..CocaCola_SFA_AddMoveOrder ''%s'', ''%s'', %d, ''%s'', ''%s'', ' +
                                                               ' ''%s'', ''%s'', ''%s'' , ''%s'', ''%s'', '+
                                                               ' ''%s'', ''%s'', ''%s'' , ''%s'', ''%s'', '+
                                                               ' ''%s'', ''%s'', ''%s''';


implementation

end.
