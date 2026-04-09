<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata"
  xmlns:mdui="urn:oasis:names:tc:SAML:metadata:ui"
  xmlns:mdattr="urn:oasis:names:tc:SAML:metadata:attribute"
  xmlns:mdrpi="urn:oasis:names:tc:SAML:metadata:rpi"
  xmlns:saml="urn:oasis:names:tc:SAML:2.0:assertion"
  xmlns:ds="http://www.w3.org/2000/09/xmldsig#"
  xmlns:alg="urn:oasis:names:tc:SAML:metadata:algsupport"
  exclude-result-prefixes="md mdui mdattr mdrpi saml ds alg">

  <xsl:output method="html" encoding="UTF-8" indent="yes" doctype-system="about:legacy-compat"/>

  <!-- ═══════════════════════════════════════════════════════════════
       ROOT
  ════════════════════════════════════════════════════════════════ -->
  <xsl:template match="/">
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <meta name="viewport" content="width=device-width, initial-scale=1"/>
        <title>SAML Metadata Viewer</title>
        <style><![CDATA[
          :root {
            --bg:         #0f1117;
            --surface:    #1a1d27;
            --surface2:   #22263a;
            --border:     #2e3352;
            --accent:     #6c8fff;
            --accent2:    #a78bfa;
            --green:      #34d399;
            --yellow:     #fbbf24;
            --red:        #f87171;
            --text:       #e2e8f0;
            --muted:      #8892b0;
            --radius:     12px;
            --font:       'Segoe UI', system-ui, -apple-system, sans-serif;
            --mono:       'Cascadia Code', 'Fira Code', 'Consolas', monospace;
          }
          * { box-sizing: border-box; margin: 0; padding: 0; }
          body {
            background: var(--bg);
            color: var(--text);
            font-family: var(--font);
            font-size: 14px;
            line-height: 1.6;
            padding: 32px 16px 64px;
          }
          a { color: var(--accent); text-decoration: none; }
          a:hover { text-decoration: underline; }

          /* ── Header ── */
          .page-header {
            max-width: 960px;
            margin: 0 auto 32px;
            display: flex;
            align-items: center;
            gap: 16px;
          }
          .page-header .logo {
            width: 48px; height: 48px;
            background: linear-gradient(135deg, var(--accent), var(--accent2));
            border-radius: 12px;
            display: flex; align-items: center; justify-content: center;
            font-size: 24px; flex-shrink: 0;
          }
          .page-header h1 {
            font-size: 22px; font-weight: 700;
            background: linear-gradient(90deg, var(--accent), var(--accent2));
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
          }
          .page-header .entity-id {
            font-family: var(--mono);
            font-size: 12px;
            color: var(--muted);
            margin-top: 2px;
            word-break: break-all;
          }

          /* ── Cards ── */
          .card {
            background: var(--surface);
            border: 1px solid var(--border);
            border-radius: var(--radius);
            max-width: 960px;
            margin: 0 auto 20px;
            overflow: hidden;
          }
          .card-header {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 14px 20px;
            background: var(--surface2);
            border-bottom: 1px solid var(--border);
            font-weight: 600;
            font-size: 13px;
            letter-spacing: .03em;
            text-transform: uppercase;
            color: var(--muted);
          }
          .card-header .icon { font-size: 18px; }
          .card-header .title-text { color: var(--text); }
          .card-body { padding: 20px; }

          /* ── Info grid ── */
          .info-grid {
            display: grid;
            grid-template-columns: 200px 1fr;
            gap: 10px 16px;
          }
          .info-label {
            color: var(--muted);
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: .05em;
            padding-top: 2px;
          }
          .info-value {
            word-break: break-all;
          }
          .info-value.mono {
            font-family: var(--mono);
            font-size: 12px;
          }

          /* ── Badges ── */
          .badge {
            display: inline-block;
            padding: 2px 8px;
            border-radius: 999px;
            font-size: 11px;
            font-weight: 600;
            letter-spacing: .03em;
          }
          .badge-blue   { background: rgba(108,143,255,.15); color: var(--accent);  border: 1px solid rgba(108,143,255,.3); }
          .badge-purple { background: rgba(167,139,250,.15); color: var(--accent2); border: 1px solid rgba(167,139,250,.3); }
          .badge-green  { background: rgba(52,211,153,.15);  color: var(--green);   border: 1px solid rgba(52,211,153,.3); }
          .badge-yellow { background: rgba(251,191,36,.15);  color: var(--yellow);  border: 1px solid rgba(251,191,36,.3); }
          .badge-red    { background: rgba(248,113,113,.15); color: var(--red);     border: 1px solid rgba(248,113,113,.3); }

          /* ── Endpoint table ── */
          .ep-table { width: 100%; border-collapse: collapse; }
          .ep-table th {
            text-align: left;
            padding: 8px 12px;
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: .05em;
            color: var(--muted);
            border-bottom: 1px solid var(--border);
          }
          .ep-table td {
            padding: 10px 12px;
            border-bottom: 1px solid rgba(46,51,82,.5);
            vertical-align: top;
          }
          .ep-table tr:last-child td { border-bottom: none; }
          .ep-table .location {
            font-family: var(--mono);
            font-size: 12px;
            word-break: break-all;
          }
          .ep-table .idx {
            color: var(--muted);
            font-size: 11px;
            font-weight: 600;
          }

          /* ── Certificate ── */
          .cert-block {
            background: var(--bg);
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 12px 16px;
            margin-bottom: 12px;
          }
          .cert-block:last-child { margin-bottom: 0; }
          .cert-meta {
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 10px;
          }
          .cert-data {
            font-family: var(--mono);
            font-size: 10px;
            color: var(--muted);
            word-break: break-all;
            line-height: 1.5;
            max-height: 80px;
            overflow: hidden;
            position: relative;
            white-space: preserve-breaks;
          }
          .cert-data::after {
            content: '';
            position: absolute;
            bottom: 0; left: 0; right: 0;
            height: 24px;
            background: linear-gradient(transparent, var(--bg));
          }

          /* ── Attributes ── */
          .attr-list { list-style: none; }
          .attr-list li {
            padding: 8px 0;
            border-bottom: 1px solid rgba(46,51,82,.5);
            display: flex;
            align-items: flex-start;
            gap: 8px;
          }
          .attr-list li:last-child { border-bottom: none; }
          .attr-icon { margin-top: 2px; }
          .attr-name { font-family: var(--mono); font-size: 12px; }
          .attr-label { color: var(--muted); font-size: 11px; }

          /* ── Contact / Org ── */
          .contact-grid {
            display: flex;
            flex-wrap: wrap;
            gap: 12px;
          }
          .contact-card {
            background: var(--bg);
            border: 1px solid var(--border);
            border-radius: 8px;
            padding: 12px 16px;
            min-width: 200px;
            flex: 1;
          }
          .contact-card .ct-type {
            font-size: 11px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: .05em;
            color: var(--muted);
            margin-bottom: 6px;
          }
          .contact-card .ct-name { font-weight: 600; margin-bottom: 4px; }

          /* ── Divider ── */
          .divider {
            border: none;
            border-top: 1px solid var(--border);
            margin: 16px 0;
          }

          /* ── Role header ── */
          .role-badge {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 4px 12px;
            border-radius: 999px;
            font-weight: 700;
            font-size: 12px;
            letter-spacing: .05em;
            text-transform: uppercase;
            margin-bottom: 16px;
          }
          .role-idp {
            background: rgba(108,143,255,.15);
            color: var(--accent);
            border: 1px solid rgba(108,143,255,.3);
          }
          .role-sp {
            background: rgba(167,139,250,.15);
            color: var(--accent2);
            border: 1px solid rgba(167,139,250,.3);
          }

          /* ── Validity ── */
          .validity-ok   { color: var(--green); }
          .validity-warn { color: var(--yellow); }
          .validity-bad  { color: var(--red); }

          /* ── Section separator inside card ── */
          .section-title {
            font-size: 11px;
            font-weight: 700;
            text-transform: uppercase;
            letter-spacing: .07em;
            color: var(--muted);
            margin: 20px 0 10px;
            display: flex;
            align-items: center;
            gap: 6px;
          }
          .section-title::after {
            content: '';
            flex: 1;
            height: 1px;
            background: var(--border);
          }

          /* ── Flags ── */
          .flag-row { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 4px; }

          /* ── Responsive ── */
          @media (max-width: 600px) {
            .info-grid { grid-template-columns: 1fr; }
            .info-label { margin-top: 8px; }
          }

          /* ── mdui logo ── */
          .mdui-logo {
            width: 64px; height: 64px;
            border-radius: 8px;
            object-fit: contain;
            background: white;
            padding: 4px;
          }
        ]]></style>
      </head>
      <body>
        <xsl:apply-templates select="//md:EntityDescriptor"/>
        <xsl:apply-templates select="//md:EntitiesDescriptor"/>
      </body>
    </html>
  </xsl:template>

  <!-- ═══════════════════════════════════════════════════════════════
       EntitiesDescriptor  (federation aggregate)
  ════════════════════════════════════════════════════════════════ -->
  <xsl:template match="md:EntitiesDescriptor">
    <div class="page-header">
      <div class="logo">🌐</div>
      <div>
        <h1>SAML Federation Metadata</h1>
        <div class="entity-id">
          <xsl:choose>
            <xsl:when test="@Name"><xsl:value-of select="@Name"/></xsl:when>
            <xsl:otherwise>(unnamed aggregate)</xsl:otherwise>
          </xsl:choose>
        </div>
      </div>
    </div>
    <xsl:apply-templates select="md:EntityDescriptor"/>
  </xsl:template>

  <!-- ═══════════════════════════════════════════════════════════════
       EntityDescriptor
  ════════════════════════════════════════════════════════════════ -->
  <xsl:template match="md:EntityDescriptor">
    <!-- Determine role icon -->
    <xsl:variable name="isIDP" select="count(md:IDPSSODescriptor) &gt; 0"/>
    <xsl:variable name="isSP"  select="count(md:SPSSODescriptor)  &gt; 0"/>
    <xsl:variable name="roleEmoji">
      <xsl:choose>
        <xsl:when test="$isIDP and $isSP">🔄</xsl:when>
        <xsl:when test="$isIDP">🏛️</xsl:when>
        <xsl:when test="$isSP">🧩</xsl:when>
        <xsl:otherwise>📄</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Derive display name from mdui or Organization -->
    <xsl:variable name="displayName">
      <xsl:choose>
        <xsl:when test="md:IDPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:DisplayName[@xml:lang='en']">
          <xsl:value-of select="md:IDPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:DisplayName[@xml:lang='en']"/>
        </xsl:when>
        <xsl:when test="md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:DisplayName[@xml:lang='en']">
          <xsl:value-of select="md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:DisplayName[@xml:lang='en']"/>
        </xsl:when>
        <xsl:when test="md:Organization/md:OrganizationDisplayName[@xml:lang='en']">
          <xsl:value-of select="md:Organization/md:OrganizationDisplayName[@xml:lang='en']"/>
        </xsl:when>
        <xsl:when test="md:Organization/md:OrganizationDisplayName">
          <xsl:value-of select="md:Organization/md:OrganizationDisplayName[1]"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@entityID"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- Page header -->
    <div class="page-header">
      <div class="logo"><xsl:value-of select="$roleEmoji"/></div>
      <div>
        <h1><xsl:value-of select="$displayName"/></h1>
        <div class="entity-id"><xsl:value-of select="@entityID"/></div>
      </div>
    </div>

    <!-- ── General info card ── -->
    <div class="card">
      <div class="card-header">
        <span class="icon">ℹ️</span>
        <span class="title-text">Entity Information</span>
      </div>
      <div class="card-body">
        <div class="info-grid">

          <div class="info-label">Entity ID</div>
          <div class="info-value mono"><xsl:value-of select="@entityID"/></div>

          <xsl:if test="@ID">
            <div class="info-label">XML ID</div>
            <div class="info-value mono"><xsl:value-of select="@ID"/></div>
          </xsl:if>

          <xsl:if test="@validUntil">
            <div class="info-label">Valid Until</div>
            <div class="info-value">
              <xsl:call-template name="format-datetime">
                <xsl:with-param name="dt" select="@validUntil"/>
              </xsl:call-template>
            </div>
          </xsl:if>

          <xsl:if test="@cacheDuration">
            <div class="info-label">Cache Duration</div>
            <div class="info-value mono"><xsl:value-of select="@cacheDuration"/></div>
          </xsl:if>

          <!-- Role -->
          <div class="info-label">Role(s)</div>
          <div class="info-value">
            <div class="flag-row">
              <xsl:if test="$isIDP">
                <span class="badge badge-blue">🏛️ Identity Provider</span>
              </xsl:if>
              <xsl:if test="$isSP">
                <span class="badge badge-purple">🧩 Service Provider</span>
              </xsl:if>
              <xsl:if test="md:AttributeAuthorityDescriptor">
                <span class="badge badge-yellow">📦 Attribute Authority</span>
              </xsl:if>
            </div>
          </div>

          <!-- Registration info -->
          <xsl:if test="md:Extensions/mdrpi:RegistrationInfo/@registrationAuthority">
            <div class="info-label">Registered By</div>
            <div class="info-value mono">
              <xsl:value-of select="md:Extensions/mdrpi:RegistrationInfo/@registrationAuthority"/>
            </div>
          </xsl:if>

        </div>

        <!-- mdui logo -->
        <xsl:if test="md:IDPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:Logo or
                      md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:Logo">
          <div class="section-title">🖼 Branding Logo</div>
          <xsl:for-each select="md:IDPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:Logo[1]|
                                 md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:Logo[1]">
            <img class="mdui-logo"
                 src="{.}"
                 alt="Entity logo"
                 onerror="this.style.display='none'"/>
          </xsl:for-each>
        </xsl:if>

        <!-- mdui description -->
        <xsl:if test="md:IDPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:Description[@xml:lang='en'] or
                      md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:Description[@xml:lang='en']">
          <div class="section-title">📝 Description</div>
          <xsl:value-of select="md:IDPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:Description[@xml:lang='en']"/>
          <xsl:value-of select="md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:Description[@xml:lang='en']"/>
        </xsl:if>

        <!-- mdui privacy / info URLs -->
        <xsl:if test="md:IDPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:PrivacyStatementURL or
                      md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:PrivacyStatementURL">
          <div class="section-title">🔒 Privacy Statement</div>
          <xsl:for-each select="md:IDPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:PrivacyStatementURL|
                                 md:SPSSODescriptor/md:Extensions/mdui:UIInfo/mdui:PrivacyStatementURL">
            <div><a href="{.}" target="_blank"><xsl:value-of select="."/></a></div>
          </xsl:for-each>
        </xsl:if>

      </div>
    </div>

    <!-- ── IdP card ── -->
    <xsl:apply-templates select="md:IDPSSODescriptor"/>

    <!-- ── SP card ── -->
    <xsl:apply-templates select="md:SPSSODescriptor"/>

    <!-- ── Organization card ── -->
    <xsl:apply-templates select="md:Organization"/>

    <!-- ── Contact persons ── -->
    <xsl:if test="md:ContactPerson">
      <div class="card">
        <div class="card-header">
          <span class="icon">👤</span>
          <span class="title-text">Contact Persons</span>
        </div>
        <div class="card-body">
          <div class="contact-grid">
            <xsl:apply-templates select="md:ContactPerson"/>
          </div>
        </div>
      </div>
    </xsl:if>

    <!-- ── Signature ── -->
    <xsl:if test="ds:Signature">
      <div class="card">
        <div class="card-header">
          <span class="icon">✍️</span>
          <span class="title-text">XML Digital Signature</span>
        </div>
        <div class="card-body">
          <span class="badge badge-green">✅ Document is signed</span>
          <xsl:if test="ds:Signature/ds:SignedInfo/ds:SignatureMethod/@Algorithm">
            <div style="margin-top:12px">
              <div class="info-grid">
                <div class="info-label">Algorithm</div>
                <div class="info-value mono">
                  <xsl:value-of select="ds:Signature/ds:SignedInfo/ds:SignatureMethod/@Algorithm"/>
                </div>
              </div>
            </div>
          </xsl:if>
        </div>
      </div>
    </xsl:if>

  </xsl:template>

  <!-- ═══════════════════════════════════════════════════════════════
       IDPSSODescriptor
  ════════════════════════════════════════════════════════════════ -->
  <xsl:template match="md:IDPSSODescriptor">
    <div class="card">
      <div class="card-header">
        <span class="icon">🏛️</span>
        <span class="title-text">Identity Provider (IdP) Descriptor</span>
      </div>
      <div class="card-body">

        <!-- Flags -->
        <div class="flag-row">
          <xsl:if test="@WantAuthnRequestsSigned = 'true'">
            <span class="badge badge-yellow">🔏 Wants Signed AuthnRequests</span>
          </xsl:if>
          <xsl:if test="@WantAuthnRequestsSigned = 'false'">
            <span class="badge badge-green">📭 AuthnRequests Unsigned OK</span>
          </xsl:if>
          <xsl:if test="@errorURL">
            <span class="badge badge-blue">🔗 Error URL set</span>
          </xsl:if>
        </div>

        <!-- NameID formats -->
        <xsl:if test="md:NameIDFormat">
          <div class="section-title">🪪 NameID Formats</div>
          <div class="flag-row">
            <xsl:for-each select="md:NameIDFormat">
              <span class="badge badge-blue"><xsl:call-template name="short-urn"><xsl:with-param name="urn" select="."/></xsl:call-template></span>
            </xsl:for-each>
          </div>
        </xsl:if>

        <!-- SSO Endpoints -->
        <xsl:if test="md:SingleSignOnService">
          <div class="section-title">🚀 Single Sign-On Services</div>
          <table class="ep-table">
            <tr>
              <th>Binding</th>
              <th>Location</th>
            </tr>
            <xsl:for-each select="md:SingleSignOnService">
              <tr>
                <td><span class="badge badge-blue"><xsl:call-template name="short-urn"><xsl:with-param name="urn" select="@Binding"/></xsl:call-template></span></td>
                <td class="location"><a href="{@Location}" target="_blank"><xsl:value-of select="@Location"/></a></td>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:if>

        <!-- SLO Endpoints -->
        <xsl:if test="md:SingleLogoutService">
          <div class="section-title">🚪 Single Logout Services</div>
          <table class="ep-table">
            <tr>
              <th>Binding</th>
              <th>Location</th>
              <th>Response Location</th>
            </tr>
            <xsl:for-each select="md:SingleLogoutService">
              <tr>
                <td><span class="badge badge-purple"><xsl:call-template name="short-urn"><xsl:with-param name="urn" select="@Binding"/></xsl:call-template></span></td>
                <td class="location"><a href="{@Location}" target="_blank"><xsl:value-of select="@Location"/></a></td>
                <td class="location">
                  <xsl:if test="@ResponseLocation">
                    <a href="{@ResponseLocation}" target="_blank"><xsl:value-of select="@ResponseLocation"/></a>
                  </xsl:if>
                </td>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:if>

        <!-- Artifact Resolution -->
        <xsl:if test="md:ArtifactResolutionService">
          <div class="section-title">🧲 Artifact Resolution Services</div>
          <xsl:call-template name="indexed-endpoints">
            <xsl:with-param name="endpoints" select="md:ArtifactResolutionService"/>
          </xsl:call-template>
        </xsl:if>

        <!-- Keys -->
        <xsl:if test="md:KeyDescriptor">
          <div class="section-title">🔑 Keys &amp; Certificates</div>
          <xsl:apply-templates select="md:KeyDescriptor"/>
        </xsl:if>

        <!-- Attributes -->
        <xsl:if test="saml:Attribute">
          <div class="section-title">📦 Supported Attributes</div>
          <ul class="attr-list">
            <xsl:for-each select="saml:Attribute">
              <li>
                <span class="attr-icon">📌</span>
                <div>
                  <div class="attr-name"><xsl:value-of select="@Name"/></div>
                  <xsl:if test="@FriendlyName">
                    <div class="attr-label"><xsl:value-of select="@FriendlyName"/></div>
                  </xsl:if>
                </div>
              </li>
            </xsl:for-each>
          </ul>
        </xsl:if>

      </div>
    </div>
  </xsl:template>

  <!-- ═══════════════════════════════════════════════════════════════
       SPSSODescriptor
  ════════════════════════════════════════════════════════════════ -->
  <xsl:template match="md:SPSSODescriptor">
    <div class="card">
      <div class="card-header">
        <span class="icon">🧩</span>
        <span class="title-text">Service Provider (SP) Descriptor</span>
      </div>
      <div class="card-body">

        <!-- Flags -->
        <div class="flag-row">
          <xsl:if test="@AuthnRequestsSigned = 'true'">
            <span class="badge badge-yellow">🔏 Signs AuthnRequests</span>
          </xsl:if>
          <xsl:if test="@WantAssertionsSigned = 'true'">
            <span class="badge badge-yellow">✅ Wants Signed Assertions</span>
          </xsl:if>
          <xsl:if test="@WantAssertionsSigned = 'false'">
            <span class="badge badge-green">📭 Unsigned Assertions OK</span>
          </xsl:if>
        </div>

        <!-- NameID formats -->
        <xsl:if test="md:NameIDFormat">
          <div class="section-title">🪪 NameID Formats</div>
          <div class="flag-row">
            <xsl:for-each select="md:NameIDFormat">
              <span class="badge badge-blue"><xsl:call-template name="short-urn"><xsl:with-param name="urn" select="."/></xsl:call-template></span>
            </xsl:for-each>
          </div>
        </xsl:if>

        <!-- ACS -->
        <xsl:if test="md:AssertionConsumerService">
          <div class="section-title">📥 Assertion Consumer Services</div>
          <table class="ep-table">
            <tr>
              <th>#</th>
              <th>Binding</th>
              <th>Location</th>
              <th>Default</th>
            </tr>
            <xsl:for-each select="md:AssertionConsumerService">
              <tr>
                <td class="idx"><xsl:value-of select="@index"/></td>
                <td><span class="badge badge-purple"><xsl:call-template name="short-urn"><xsl:with-param name="urn" select="@Binding"/></xsl:call-template></span></td>
                <td class="location"><a href="{@Location}" target="_blank"><xsl:value-of select="@Location"/></a></td>
                <td>
                  <xsl:choose>
                    <xsl:when test="@isDefault = 'true'"><span class="badge badge-green">⭐ Yes</span></xsl:when>
                    <xsl:otherwise><span style="color:var(--muted)">—</span></xsl:otherwise>
                  </xsl:choose>
                </td>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:if>

        <!-- SLO -->
        <xsl:if test="md:SingleLogoutService">
          <div class="section-title">🚪 Single Logout Services</div>
          <table class="ep-table">
            <tr>
              <th>Binding</th>
              <th>Location</th>
            </tr>
            <xsl:for-each select="md:SingleLogoutService">
              <tr>
                <td><span class="badge badge-purple"><xsl:call-template name="short-urn"><xsl:with-param name="urn" select="@Binding"/></xsl:call-template></span></td>
                <td class="location"><a href="{@Location}" target="_blank"><xsl:value-of select="@Location"/></a></td>
              </tr>
            </xsl:for-each>
          </table>
        </xsl:if>

        <!-- Artifact -->
        <xsl:if test="md:ArtifactResolutionService">
          <div class="section-title">🧲 Artifact Resolution Services</div>
          <xsl:call-template name="indexed-endpoints">
            <xsl:with-param name="endpoints" select="md:ArtifactResolutionService"/>
          </xsl:call-template>
        </xsl:if>

        <!-- Keys -->
        <xsl:if test="md:KeyDescriptor">
          <div class="section-title">🔑 Keys &amp; Certificates</div>
          <xsl:apply-templates select="md:KeyDescriptor"/>
        </xsl:if>

        <!-- Attribute Consuming Services -->
        <xsl:if test="md:AttributeConsumingService">
          <div class="section-title">📦 Requested Attributes</div>
          <xsl:apply-templates select="md:AttributeConsumingService"/>
        </xsl:if>

      </div>
    </div>
  </xsl:template>

  <!-- ═══════════════════════════════════════════════════════════════
       KeyDescriptor
  ════════════════════════════════════════════════════════════════ -->
  <xsl:template match="md:KeyDescriptor">
    <div class="cert-block">
      <div class="cert-meta">
        <xsl:choose>
          <xsl:when test="@use = 'signing'">
            <span class="badge badge-yellow">✍️ Signing</span>
          </xsl:when>
          <xsl:when test="@use = 'encryption'">
            <span class="badge badge-blue">🔐 Encryption</span>
          </xsl:when>
          <xsl:otherwise>
            <span class="badge badge-green">🔑 Signing &amp; Encryption</span>
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <xsl:if test=".//ds:X509Certificate">
        <div class="cert-data">
          -----BEGIN CERTIFICATE-----
          <xsl:value-of select="normalize-space(.//ds:X509Certificate)"/>
          -----END CERTIFICATE-----
        </div>
      </xsl:if>
      <xsl:if test=".//ds:KeyName">
        <div style="margin-top:8px;font-size:12px;color:var(--muted)">
          Key Name: <xsl:value-of select=".//ds:KeyName"/>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <!-- ═══════════════════════════════════════════════════════════════
       AttributeConsumingService
  ════════════════════════════════════════════════════════════════ -->
  <xsl:template match="md:AttributeConsumingService">
    <div style="margin-bottom:16px">
      <div style="margin-bottom:8px;display:flex;align-items:center;gap:8px">
        <span class="badge badge-blue">Index <xsl:value-of select="@index"/></span>
        <xsl:if test="@isDefault='true'"><span class="badge badge-green">⭐ Default</span></xsl:if>
        <xsl:if test="md:ServiceName[@xml:lang='en']">
          <strong><xsl:value-of select="md:ServiceName[@xml:lang='en']"/></strong>
        </xsl:if>
      </div>
      <xsl:if test="md:ServiceDescription[@xml:lang='en']">
        <div style="color:var(--muted);font-size:12px;margin-bottom:8px"><xsl:value-of select="md:ServiceDescription[@xml:lang='en']"/></div>
      </xsl:if>
      <ul class="attr-list">
        <xsl:for-each select="md:RequestedAttribute">
          <li>
            <span class="attr-icon">
              <xsl:choose>
                <xsl:when test="@isRequired='true'">🔴</xsl:when>
                <xsl:otherwise>🟡</xsl:otherwise>
              </xsl:choose>
            </span>
            <div>
              <div class="attr-name"><xsl:value-of select="@Name"/></div>
              <div style="display:flex;gap:6px;margin-top:2px">
                <xsl:if test="@FriendlyName">
                  <span class="attr-label"><xsl:value-of select="@FriendlyName"/></span>
                </xsl:if>
                <xsl:if test="@isRequired='true'">
                  <span class="badge badge-red" style="font-size:10px">Required</span>
                </xsl:if>
                <xsl:if test="not(@isRequired='true')">
                  <span class="badge badge-yellow" style="font-size:10px">Optional</span>
                </xsl:if>
              </div>
            </div>
          </li>
        </xsl:for-each>
      </ul>
    </div>
  </xsl:template>

  <!-- ═══════════════════════════════════════════════════════════════
       Organization
  ════════════════════════════════════════════════════════════════ -->
  <xsl:template match="md:Organization">
    <div class="card">
      <div class="card-header">
        <span class="icon">🏢</span>
        <span class="title-text">Organization</span>
      </div>
      <div class="card-body">
        <div class="info-grid">
          <xsl:if test="md:OrganizationName[@xml:lang='en']">
            <div class="info-label">Name</div>
            <div class="info-value"><xsl:value-of select="md:OrganizationName[@xml:lang='en']"/></div>
          </xsl:if>
          <xsl:if test="not(md:OrganizationName[@xml:lang='en']) and md:OrganizationName">
            <div class="info-label">Name</div>
            <div class="info-value"><xsl:value-of select="md:OrganizationName[1]"/></div>
          </xsl:if>
          <xsl:if test="md:OrganizationDisplayName[@xml:lang='en']">
            <div class="info-label">Display Name</div>
            <div class="info-value"><xsl:value-of select="md:OrganizationDisplayName[@xml:lang='en']"/></div>
          </xsl:if>
          <xsl:if test="md:OrganizationURL[@xml:lang='en']">
            <div class="info-label">Website</div>
            <div class="info-value"><a href="{md:OrganizationURL[@xml:lang='en']}" target="_blank"><xsl:value-of select="md:OrganizationURL[@xml:lang='en']"/></a></div>
          </xsl:if>
          <xsl:if test="not(md:OrganizationURL[@xml:lang='en']) and md:OrganizationURL">
            <div class="info-label">Website</div>
            <div class="info-value"><a href="{md:OrganizationURL[1]}" target="_blank"><xsl:value-of select="md:OrganizationURL[1]"/></a></div>
          </xsl:if>
        </div>
      </div>
    </div>
  </xsl:template>

  <!-- ═══════════════════════════════════════════════════════════════
       ContactPerson
  ════════════════════════════════════════════════════════════════ -->
  <xsl:template match="md:ContactPerson">
    <div class="contact-card">
      <div class="ct-type">
        <xsl:choose>
          <xsl:when test="@contactType='technical'">🔧 Technical</xsl:when>
          <xsl:when test="@contactType='support'">💬 Support</xsl:when>
          <xsl:when test="@contactType='administrative'">🗂️ Administrative</xsl:when>
          <xsl:when test="@contactType='billing'">💳 Billing</xsl:when>
          <xsl:when test="@contactType='other'">👤 Other</xsl:when>
          <xsl:otherwise><xsl:value-of select="@contactType"/></xsl:otherwise>
        </xsl:choose>
      </div>
      <div class="ct-name">
        <xsl:if test="md:GivenName"><xsl:value-of select="md:GivenName"/><xsl:text> </xsl:text></xsl:if>
        <xsl:if test="md:SurName"><xsl:value-of select="md:SurName"/></xsl:if>
        <xsl:if test="not(md:GivenName) and not(md:SurName)">—</xsl:if>
      </div>
      <xsl:if test="md:Company">
        <div style="color:var(--muted);font-size:12px"><xsl:value-of select="md:Company"/></div>
      </xsl:if>
      <xsl:for-each select="md:EmailAddress">
        <div style="margin-top:4px">
          <a href="mailto:{.}">
            ✉️
            <xsl:value-of select="substring-after(., 'mailto:')"/>
            <xsl:if test="not(contains(., 'mailto:'))"><xsl:value-of select="."/></xsl:if>
          </a>
        </div>
      </xsl:for-each>
      <xsl:for-each select="md:TelephoneNumber">
        <div style="margin-top:4px">
          <a href="tel:{.}">
            📞
            <xsl:value-of select="substring-after(., 'tel:')"/>
            <xsl:if test="not(contains(., 'tel:'))"><xsl:value-of select="."/></xsl:if>
          </a>
        </div>
      </xsl:for-each>
    </div>
  </xsl:template>

  <!-- ═══════════════════════════════════════════════════════════════
       NAMED TEMPLATES
  ════════════════════════════════════════════════════════════════ -->

  <!-- Shorten SAML URNs to a human-readable label -->
  <xsl:template name="short-urn">
    <xsl:param name="urn"/>
    <xsl:choose>
      <!-- Bindings -->
      <xsl:when test="$urn = 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST'">HTTP-POST</xsl:when>
      <xsl:when test="$urn = 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect'">HTTP-Redirect</xsl:when>
      <xsl:when test="$urn = 'urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Artifact'">HTTP-Artifact</xsl:when>
      <xsl:when test="$urn = 'urn:oasis:names:tc:SAML:2.0:bindings:PAOS'">PAOS (ECP)</xsl:when>
      <xsl:when test="$urn = 'urn:oasis:names:tc:SAML:2.0:bindings:SOAP'">SOAP</xsl:when>
      <!-- NameID formats -->
      <xsl:when test="$urn = 'urn:oasis:names:tc:SAML:2.0:nameid-format:persistent'">persistent</xsl:when>
      <xsl:when test="$urn = 'urn:oasis:names:tc:SAML:2.0:nameid-format:transient'">transient</xsl:when>
      <xsl:when test="$urn = 'urn:oasis:names:tc:SAML:2.0:nameid-format:emailAddress'">emailAddress</xsl:when>
      <xsl:when test="$urn = 'urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress'">emailAddress (SAML1)</xsl:when>
      <xsl:when test="$urn = 'urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified'">unspecified</xsl:when>
      <xsl:when test="$urn = 'urn:oasis:names:tc:SAML:2.0:nameid-format:unspecified'">unspecified</xsl:when>
      <xsl:when test="$urn = 'urn:oasis:names:tc:SAML:2.0:nameid-format:entity'">entity</xsl:when>
      <xsl:when test="$urn = 'urn:oasis:names:tc:SAML:1.1:nameid-format:X509SubjectName'">X509SubjectName</xsl:when>
      <xsl:when test="$urn = 'urn:oasis:names:tc:SAML:2.0:nameid-format:kerberos'">kerberos</xsl:when>
      <xsl:when test="$urn = 'urn:oasis:names:tc:SAML:1.1:nameid-format:WindowsDomainQualifiedName'">WindowsDomainQualifiedName</xsl:when>
      <!-- Fallback: strip common SAML URN prefix -->
      <xsl:when test="starts-with($urn, 'urn:oasis:names:tc:SAML:')">
        <xsl:value-of select="substring-after($urn, 'urn:oasis:names:tc:SAML:')"/>
      </xsl:when>
      <xsl:otherwise><xsl:value-of select="$urn"/></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Format ISO datetime nicely -->
  <xsl:template name="format-datetime">
    <xsl:param name="dt"/>
    <!-- e.g. 2025-08-30T19:10:29Z → "2025-08-30 19:10:29 UTC" -->
    <xsl:value-of select="translate(substring($dt, 1, 19), 'T', ' ')"/>
    <xsl:if test="contains($dt, 'Z')"> UTC</xsl:if>
  </xsl:template>

  <!-- Render a list of indexed endpoints (e.g. ArtifactResolutionService) -->
  <xsl:template name="indexed-endpoints">
    <xsl:param name="endpoints"/>
    <table class="ep-table">
      <tr>
        <th>#</th>
        <th>Binding</th>
        <th>Location</th>
        <th>Default</th>
      </tr>
      <xsl:for-each select="$endpoints">
        <tr>
          <td class="idx"><xsl:value-of select="@index"/></td>
          <td><span class="badge badge-blue"><xsl:call-template name="short-urn"><xsl:with-param name="urn" select="@Binding"/></xsl:call-template></span></td>
          <td class="location"><a href="{@Location}" target="_blank"><xsl:value-of select="@Location"/></a></td>
          <td>
            <xsl:choose>
              <xsl:when test="@isDefault='true'"><span class="badge badge-green">⭐ Yes</span></xsl:when>
              <xsl:otherwise><span style="color:var(--muted)">—</span></xsl:otherwise>
            </xsl:choose>
          </td>
        </tr>
      </xsl:for-each>
    </table>
  </xsl:template>

</xsl:stylesheet>
