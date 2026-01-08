# hardengkec ☸️🪨🧭
hardengkec : Hardening GKE Cluster # PodSecurityPolicy 


## Objective
- Create a small GKE cluster using the default settings.
- Validate the most common paths of pod escape and cluster privilege escalation from the perspective of a malicious internal user.
- Harden the GKE cluster for these issues.
- Validate the cluster so that those actions are no longer allowed.
- These attack paths are relevant in the following scenarios:
    - An application flaw in an external facing pod that allows for Server-Side Request Forgery (SSRF) attacks.
    - A fully compromised container inside a pod allowing for Remote Command Execution (RCE).
    - A malicious internal user or an attacker with a set of compromised internal user credentials with the ability to create/update a pod in a given namespace.
- Understand the available controls
    - Disabling the Legacy Compute Engine Metadata API Endpoint - By specifying a custom metadata key and value, the v1beta1 metadata endpoint will no longer be available from the instance.
    - Enable Metadata Concealment - Passing an additional configuration during cluster and/or node pool creation, a lightweight proxy will be installed on each node that proxies all requests to the Metadata API and prevents access to sensitive endpoints.
    - Enable and Utilize Pod Security Admission - Enable the Pod Security Admission (PSA) controller in your GKE cluster. This provides the ability to enforce pod security standards that enhance your cluster's security posture.


## Hardening Default GKE Cluster Configurations

![hardengkec001.png](./media/hardengkec001.png)

![hardengkec002.png](./media/hardengkec002.png)

![hardengkec003.png](./media/hardengkec003.png)

![hardengkec004.png](./media/hardengkec004.png)

![hardengkec005.png](./media/hardengkec005.png)

![hardengkec006.png](./media/hardengkec006.png)

![hardengkec007.png](./media/hardengkec007.png)

![hardengkec008.png](./media/hardengkec008.png)

![hardengkec009.png](./media/hardengkec009.png)

![hardengkec010.png](./media/hardengkec010.png)

![hardengkec011.png](./media/hardengkec011.png)

![hardengkec012.png](./media/hardengkec012.png)

![hardengkec013.png](./media/hardengkec013.png)

![hardengkec014.png](./media/hardengkec014.png)

![hardengkec015.png](./media/hardengkec015.png)

![hardengkec016.png](./media/hardengkec016.png)

![hardengkec017.png](./media/hardengkec017.png)

![hardengkec018.png](./media/hardengkec018.png)

![hardengkec019.png](./media/hardengkec019.png)

![hardengkec020.png](./media/hardengkec020.png)

![hardengkec021.png](./media/hardengkec021.png)

![hardengkec022.png](./media/hardengkec022.png)

![hardengkec023.png](./media/hardengkec023.png)

![hardengkec024.png](./media/hardengkec024.png)

![hardengkec025.png](./media/hardengkec025.png)

![hardengkec026.png](./media/hardengkec026.png)

![hardengkec027.png](./media/hardengkec027.png)

![hardengkec028.png](./media/hardengkec028.png)

![hardengkec029.png](./media/hardengkec029.png)

![hardengkec030.png](./media/hardengkec030.png)
