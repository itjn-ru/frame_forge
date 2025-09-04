enum ProcessStatusIdEnum{
  created('46ded70e-cde9-42d2-9f51-6f102fd911b0','Создан'),
  outgoing('5fa9ed2b-5fab-4b41-b2fd-bbeb738c2f26','Отправлен'),
  forSignature('for-signature','На подпись'),
  waitingForSignatory('waiting-for-signatory','Ждем подписанта'),
  signed('signed','Подписан'),
  closed('closed','Завершен'),
  incoming('incoming','Входящий'),
  unknown('','');

  final String value;
  final String title;
  const ProcessStatusIdEnum(this.value, this.title);
}