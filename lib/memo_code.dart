/*Action Codes
Action	Prefix	Values	Status	Example
Set name	0x6d01
<name> (1-217 bytes)

Post memo	0x6d02
<message> (1-217 bytes)

Reply to memo	0x6d03
<tx_hash> (32 bytes)
<message> (1-184 bytes)

Like / tip memo	0x6d04
<tx_hash> (32 bytes)

Set profile text	0x6d05
<text> (1-217 bytes)

Follow user	0x6d06
<address> (20 bytes)

Unfollow user	0x6d07
<address> (20 bytes)

Set profile picture	0x6d0a
<url> (1-217 bytes)

Post topic message	0x6d0c
<topic_name> (1-214 bytes)
<message> (1-[214-len(topic_name)] bytes)

Topic follow	0x6d0d
<topic_name> (1-214 bytes)

Topic unfollow	0x6d0e
<topic_name> (1-214 bytes)

Create poll	0x6d10
<poll_type> (1 byte)
<option_count> (1 byte)
<question> (1-209 bytes)

Add poll option	0x6d13
<poll_tx_hash> (32 bytes)
<option> (1-184 bytes)

Poll vote	0x6d14
<poll_tx_hash> (32 bytes)
<comment> (0-184 bytes)

Mute user	0x6d16
<address_hash> (20 bytes)

Unmute user	0x6d17
<address_hash> (20 bytes)

Send money	0x6d24
<address_hash> (20 bytes)
<message> (1-194 bytes)

Sell tokens
Spec	0x6d30
<input/output_1>
...
<input/output_n>

Token buy offer
Spec	0x6d31
<list_sale_hash> (30 bytes)
<input/output_1>
...
<input/output_n>

Attach token sale signature
Spec	0x6d32
<sale_offer_hash> (30 bytes)
<signature_1> (72 bytes)
<input/output_n> (72 bytes)

Pin token post	0x6d35
<post_tx_hash> (30 bytes)
<token_utxo_hash> (30 bytes)
<token_utxo_index> (1 byte)

Link request	0x6d20
<address_hash> (20 bytes)
<message> (1-194 bytes)

Link accept	0x6d21
<request_tx_hash> (30 bytes)
<message> (1-184 bytes)

Link revoke	0x6d22
<accept_tx_hash> (30 bytes)
<message> (1-184 bytes)

Set address alias	0x6d26
<address_hash> (20 bytes)
<alias> (1-194 bytes)

*/

enum MemoCode {
  SetProfileName(opCode: "6d01"),
  SetProfileText(opCode: "6d05"),
  SetProfileImgUrl(opCode: "6d0a"),
  ProfilePostMessage(opCode: "6d02"),
  TopicPostMessage(opCode: "6d0c"),
  TopicFollow(opCode: "6d0d"),
  TopicFollowUndo(opCode: "6d0e");

  final String opCode;

  const MemoCode ({
    required this.opCode
  });
}