package id.my.direkapin.app

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.graphics.BitmapFactory
import android.graphics.Color
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import java.time.LocalDate
import java.time.ZoneId

/** Lapisan surface di atas gambar latar (55%), supaya angka tetap kebaca (D-83). */
private const val SCRIM_ALPHA = 140

/**
 * Widget "Hari ini" (ENG-05). Hanya menampilkan teks + warna + gambar yang ditulis app
 * (`lib/core/home_widget/today_widget.dart`); tidak pernah mengambil data sendiri.
 */
class TodayWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        for (id in appWidgetIds) {
            appWidgetManager.updateAppWidget(id, build(context, widgetData))
        }
    }

    /** Ukuran tetap 2×2 (D-85): satu tata letak, tanpa cabang per ukuran. */
    private fun build(context: Context, data: SharedPreferences): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.today_widget)
        fun color(key: String, fallback: Int): Int =
            data.getString(key, null)?.let { runCatching { Color.parseColor(it) }.getOrNull() }
                ?: fallback

        val surface = color("surface", Color.WHITE)
        val text = color("text", Color.BLACK)
        val secondary = color("textSecondary", Color.DKGRAY)
        val ink = color("ink", Color.BLACK)
        views.setInt(R.id.fill, "setColorFilter", surface)
        views.setInt(R.id.scrim, "setColorFilter", surface)
        views.setInt(R.id.scrim, "setImageAlpha", SCRIM_ALPHA)
        views.setInt(R.id.frame, "setColorFilter", ink)
        views.setInt(R.id.add_fill, "setColorFilter", color("accent", Color.LTGRAY))
        views.setInt(R.id.add_ring, "setColorFilter", ink)
        views.setTextColor(R.id.add_plus, ink)
        views.setTextColor(R.id.title, secondary)
        views.setTextColor(R.id.expense_label, secondary)
        views.setTextColor(R.id.income_label, secondary)

        val date = data.getString("date", null)
        if (date == null) {
            views.setTextColor(R.id.expense, text)
            views.setTextViewText(R.id.expense, "Masuk dulu")
            views.setViewVisibility(R.id.expense_label, View.GONE)
            views.setViewVisibility(R.id.income_label, View.GONE)
            views.setViewVisibility(R.id.income, View.GONE)
        } else {
            // App belum dibuka hari ini: jangan tampilkan angka kemarin sebagai hari ini.
            // Zona waktu profil (sama dengan server), bukan zona HP.
            val zone = data.getString("timezone", null)
                ?.let { runCatching { ZoneId.of(it) }.getOrNull() }
                ?: ZoneId.systemDefault()
            val isToday = date == LocalDate.now(zone).toString()
            val expense = if (isToday) data.getString("expense", null) ?: "−Rp0" else "−Rp0"
            val income = if (isToday) data.getString("income", null) ?: "+Rp0" else "+Rp0"
            views.setTextViewText(R.id.expense, expense)
            views.setTextViewText(R.id.income, income)
            views.setTextColor(R.id.expense, color("expenseColor", text))
            views.setTextColor(R.id.income, color("incomeColor", text))
            for (id in intArrayOf(R.id.expense_label, R.id.income_label, R.id.income)) {
                views.setViewVisibility(id, View.VISIBLE)
            }
        }

        // Foto: persegi 360 px dari editor bingkai di app (D-85), opaque. RGB_565 =
        // separuh memori ARGB supaya aman lewat binder; PNG ber-alpha → paksa salin.
        val photo = data.getString("image", null)
            ?.let { BitmapFactory.decodeFile(it) }
            ?.let {
                if (it.config == android.graphics.Bitmap.Config.RGB_565) it
                else it.copy(android.graphics.Bitmap.Config.RGB_565, false)
            }
        // Maskot: transparan 360 px, utuh setinggi widget di kanan bawah (fitEnd).
        val mascot = if (photo == null) {
            data.getString("mascot", null)?.let { BitmapFactory.decodeFile(it) }
        } else {
            null
        }
        // File hilang (HP dibersihkan) atau rusak: tetap tampil dengan latar polos tema.
        show(views, R.id.image, photo)
        show(views, R.id.mascot, mascot)

        views.setOnClickPendingIntent(
            R.id.add,
            HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("direkapin://catat"),
            ),
        )
        views.setOnClickPendingIntent(
            android.R.id.background,
            HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java),
        )
        return views
    }

    private fun show(views: RemoteViews, id: Int, bitmap: android.graphics.Bitmap?) {
        if (bitmap == null) return views.setViewVisibility(id, View.GONE)
        views.setImageViewBitmap(id, bitmap)
        views.setViewVisibility(id, View.VISIBLE)
    }
}
