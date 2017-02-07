# Tier1-WatchDog
<h2>In the nutshell</h2>
<p>Tier1_WatchDog_V2.py -t &lt;TimeToReact&gt; -v &lt;VendorID&gt; -p &lt;ProductID&gt; -l &lt;LoggingLevel&gt; -c &lt;CheckTimeOut&gt; -q &lt;Queue&gt; [-u &lt;Users&gt;, -s &lt;Snooze&gt;]</p>
<p>It's a tiny script to check SLAs and cases in any Tier 1 Support queue - German, French, Italian, Europe or any other.</p>
<p>Script loads case info from a specified queue and finds a case, where CaseMilestone:<span style="color: rgb(0,0,0);">FirstResponse is not<strong> </strong>
    <span style="color: rgb(74,74,86);">Completed = True. </span>
  </span>
</p>
<p>
  <span style="color: rgb(0,0,0);">
    <span style="color: rgb(74,74,86);">Then, if [CaseMilestone:<span style="color: rgb(0,0,0);">FirstResponse<strong>:</strong>
      </span>
    </span>
  </span>
  <span style="color: rgb(74,74,86);">
    <span style="color: rgb(51,153,102);">Target Response</span>] - [CurrentTime] &lt; <span style="color: rgb(0,0,255);">
      <strong>TimeToReact</strong>
    </span>:</span>
</p>
<p>
  <span style="color: rgb(74,74,86);">           - Make alarm using any attached HID device</span>
</p>
<p>
  <span style="color: rgb(74,74,86);">else:</span>
</p>
<p>
  <span style="color: rgb(74,74,86);">          - Sleep <span style="color: rgb(0,0,255);">
      <strong>CheckTimeOut</strong>
    </span>
  </span>
</p>
<p>In case, when alarm was already started, <span style="color: rgb(0,0,255);">
    <strong>Snooze </strong>
  </span>option could deactivate it while <span style="color: rgb(0,0,255);">
    <strong>CheckTimeOut</strong>
  </span>
</p>
<p>
  <span style="color: rgb(74,74,86);">
    <span style="color: rgb(0,0,0);">You also can specify <span style="color: rgb(0,0,255);">
        <strong>Users <span style="color: rgb(0,0,0);"> </span>
        </strong>
        <span style="color: rgb(0,0,0);">to watch by using -u or --Users option. Principle is same - WatchDog will search for cases, owned by specific users and react if CaseMilestone:<span style="color: rgb(0,0,0);">FirstResponse:</span>
          <span style="color: rgb(74,74,86);">Completed != True and <span style="color: rgb(0,0,0);">
              <span style="color: rgb(74,74,86);">[CaseMilestone:<span style="color: rgb(0,0,0);">FirstResponse<strong>:</strong>
                </span>
              </span>
            </span>
            <span style="color: rgb(74,74,86);">
              <span style="color: rgb(51,153,102);">Target Response</span>] - [CurrentTime] &lt; <span style="color: rgb(0,0,255);">
                <strong>TimeToReact.</strong>
              </span>
            </span>
          </span>
        </span>
      </span>
    </span>
  </span>
</p>
<h2>Usage</h2>
<table>
  <tbody>
    <tr>
      <th>Option</th>
      <th>
        <span>Argument</span>
      </th>
    </tr>
    <tr>
      <td>-t, --TimeToReact</td>
      <td>smallest allowed FTR time before to trigger an action, min</td>
    </tr>
    <tr>
      <td>-v, --VendorID</td>
      <td>ID of USB HID Vendor, recommended: "0x20a0"'</td>
    </tr>
    <tr>
      <td>-p, --ProductID</td>
      <td>ID of USB <span>HID </span>Product, recommended: "0x4173"'</td>
    </tr>
    <tr>
      <td>-l, --LoggingLevel</td>
      <td>"DEBUG", "INFO" or "WARNING"'</td>
    </tr>
    <tr>
      <td>-c, --CheckTimeOut</td>
      <td>frequency of queue recheck, sec, recommended: "20"'</td>
    </tr>
    <tr>
      <td colspan="1">-q, --Queue</td>
      <td colspan="1">
        <p>queue to watch, supported:</p>
        <table>
          <tbody>
            <tr>
              <th>Tier </th>
              <th>what to type</th>
            </tr>
            <tr>
              <td>Tier German</td>
              <td>German</td>
            </tr>
            <tr>
              <td>Tier French</td>
              <td>
                <span>French</span>
              </td>
            </tr>
            <tr>
              <td colspan="1">Tier Italian</td>
              <td colspan="1">
                <span>Italian</span>
              </td>
            </tr>
            <tr>
              <td>Tier Europe</td>
              <td>
                <span>Europe</span>
              </td>
            </tr>
          </tbody>
        </table>
      </td>
    </tr>
    <tr>
      <td colspan="1">-u, --Users</td>
      <td colspan="1">"FirstName LastName, FirstName LastName, FirstName LastName". Use "," as separator, start and finish with " sign</td>
    </tr>
    <tr>
      <td colspan="1">-s, --Snooze</td>
      <td colspan="1">True or False</td>
    </tr>
  </tbody>
</table>
<h2>Example</h2>
python Tier1_WatchDog_V2.py -t 30 -v 0x20a0 -p 0x4173 -l WARNING -c 20 -q German -u "Dmitriy Rozhdestvenskiy" -s True


