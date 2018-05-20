
extern void DES(unsigned char *source,unsigned char * dest,unsigned char * inkey, int flg);
extern void DES3_encrypt(unsigned char *plain_text,unsigned char *key_text,unsigned char *encrypt_text);
extern void DES3_decrypt(unsigned char *encrypt_text,unsigned char *key_text,unsigned char *plain_text);