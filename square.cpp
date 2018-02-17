#include "square.h"
#include "piece.h"
Square::Square()
{
    m_highlight = false;
}

QByteArray Square::serialize()
{

    QByteArray rv;
    QDataStream stream(&rv, QIODevice::WriteOnly);
    stream << m_row << m_col << m_piece->m_owner << m_piece->m_rank;
    return qCompress(rv,9).toHex();

}

void Square::highlight(bool should_highlight)
{
    m_highlight = should_highlight;
emit this->highlight_changed(should_highlight);
}
