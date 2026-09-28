# Runbook

## 2026-09-28 — SSH connection timed out

**Symptom:** `ssh -i cloud-lab.pem ec2-user@<ip>` → Connection timed out.
Ping bhi fail. `Test-NetConnection` → TcpTestSucceeded: False.

**Kaise dhoondha:**
1. Instance Running hai? — haan, 3/3 checks passed
2. Sahi SG laga hai? — haan, cloud-lab-sg
3. SSH rule ka source? — 47.11.17.170, par mera IP 47.11.0.146 tha
4. Test: source 0.0.0.0/0 kiya → connect ho gaya → matlab IP ki problem hai
5. Andar se `echo $SSH_CLIENT` → 47.11.9.203 (teesra alag IP)

**Asli wajah:** ISP CGNAT — har connection pe alag public IP deta hai.
47.11.0.0/16 rakhne se bhi kaam nahi chala.

**Fix:** Session Manager. IAM role `ec2-ssm-role` banaya
(policy: AmazonSSMManagedInstanceCore), instance pe attach kiya.
Ab port 22 chahiye hi nahi — SG se SSH rule delete kar diya.

**Seekha:** Timeout = packet pahunch hi nahi raha (firewall/SG).
"Permission denied" hota toh chaabi ki problem hoti.
