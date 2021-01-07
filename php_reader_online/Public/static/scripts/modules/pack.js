/* Copyright (C) By Jingziming<zimingcafe@gmail.com> */

~(function (window, undefined) {

    var jQuery = window.jQuery, document = window.document;

    var sc = document.getElementById('select_channel');
    var sc_value = document.getElementById('channel_name');
    var s_cpu = document.getElementById('select_cpu');
    var s_cpu_value = document.getElementById('cpu_name');

    jQuery.get('/index.php?s=/update_pack/getChannels', function(response) {

        if (!(rp = JSON.parse(response)) || rp.status != 200) { return false; }

        var oFrag = document.createDocumentFragment();

        var data = rp.data, data_length = data.length;
        for (i = 0; i < data_length; i++) {
            var opt = document.createElement('option');
            opt.value = data[i].name;
            opt.text = data[i].name;
            oFrag.appendChild(opt);
        }
        sc.appendChild(oFrag)

        $('#select_channel').on('change', function(item) {
            if (sc.value != 0) {
                sc_value.value = sc.value;
            }
        });
    });

    var oFrag = document.createDocumentFragment();

    var data = ['armeabi', 'armeabi-v7a', 'x86', 'mips', 'arm64- v8a', 'mips64', 'x86_64'], data_length = data.length;
    for (i = 0; i < data_length; i++) {
        var opt = document.createElement('option');
        opt.value = data[i];
        opt.text = data[i];
        oFrag.appendChild(opt);
    }
    s_cpu.appendChild(oFrag);

    $('#select_cpu').on('change', function(item) {
        if (s_cpu.value != 0) {
            s_cpu_value.value = s_cpu.value;
        }
    });

})(window, void 0);