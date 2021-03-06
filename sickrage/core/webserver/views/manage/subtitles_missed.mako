<%inherit file="../layouts/main.mako"/>
<%!
    import datetime

    import sickrage
    import sickrage.subtitles
%>
<%block name="content">
    <div class="row">
        <div class="col-lg-10 mx-auto">
            <div class="card">
                <div class="card-header">
                    <h3>${title}</h3>
                </div>
                <div class="card-body">
                    % if whichSubs:
                        <% subsLanguage = sickrage.subtitles.name_from_code(whichSubs) if not whichSubs == 'all' else 'All' %>
                    % endif
                    % if not whichSubs or (whichSubs and not ep_counts):
                    % if whichSubs:
                        <h2>${_('All of your episodes have')} ${subsLanguage} ${_('subtitles.')}</h2>
                        <br>
                    % endif

                        <form action="${srWebRoot}/manage/subtitleMissed" method="get">
                            ${_('Manage episodes without')}
                            <div class="input-group">
                                % if sickrage.app.config.subtitles_multi:
                                    <select name="whichSubs" class="form-control form-control-inline input-sm">
                                        <option value="all">All</option>
                                        % for sub_code in sickrage.subtitles.wanted_languages():
                                            <option value="${sub_code}">${sickrage.subtitles.name_from_code(sub_code)}</option>
                                        % endfor
                                    </select>
                                % else:
                                    <select name="whichSubs" class="form-control form-control-inline input-sm">
                                        % if not sickrage.subtitles.wanted_languages():
                                            <option value="all">All</option>
                                        % else:
                                            % for index, sub_code in enumerate(sickrage.subtitles.wanted_languages()):
                                                % if index == 0:
                                                    <option value="und">${sickrage.subtitles.name_from_code(sub_code)}</option>
                                                % endif
                                            % endfor
                                        % endif
                                    </select>
                                % endif
                                <div class="input-group-append">
                                    <input class="btn" type="submit" value="${_('Manage')}"/>
                                </div>
                            </div>

                        </form>

                    % else:
                        <input type="hidden" id="selectSubLang" name="selectSubLang" value="${whichSubs}"/>

                        <form action="${srWebRoot}/manage/downloadSubtitleMissed" method="post">
                            % if sickrage.app.config.subtitles_multi:
                                <h2>${_('Episodes without')} ${subsLanguage} ${_('subtitles.')}</h2>
                            % else:
                                % for index, sub_code in enumerate(sickrage.subtitles.wanted_languages()):
                                    % if index == 0:
                                        <h2>${_('Episodes without')} ${sickrage.subtitles.name_from_code(sub_code)} ${_('(undefined) subtitles.')}</h2>
                                    % endif
                                % endfor
                            % endif
                            <br>
                            ${_('Download missed subtitles for selected episodes')} <input class="btn btn-inline"
                                                                                           type="submit"
                                                                                           value="${_('Go')}"/>
                            <div>
                                <button type="button" class="btn selectAllShows">${_('Select all')}</button>
                                <button type="button" class="btn unselectAllShows">${_('Clear all')}</button>
                            </div>
                            <br>
                            <div class="table-responsive">
                                <table class="table">
                                    % for cur_indexer_id in sorted_show_ids:
                                        <tr id="${cur_indexer_id}">
                                            <th style="width: 1%;">
                                                <input type="checkbox" class="allCheck" id="allCheck-${cur_indexer_id}"
                                                       name="${cur_indexer_id}-all" checked/>
                                            </th>
                                            <th colspan="3" style="text-align: left;">
                                                <a class="whitelink"
                                                   href="${srWebRoot}/home/displayShow?show=${cur_indexer_id}">
                                                    ${show_names[cur_indexer_id]}
                                                </a>
                                                (${ep_counts[cur_indexer_id]})
                                                <input type="button" class="btn get_more_eps"
                                                       id="${cur_indexer_id}" value="${_('Expand')}"/>
                                            </th>
                                        </tr>
                                    % endfor
                                </table>
                            </div>
                        </form>
                    % endif
                </div>
            </div>
        </div>
    </div>
</%block>
