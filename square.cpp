#include "square.h"
#include "piece.h"
Square::Square()
{
    m_highlight = false;
}

QByteArray Square::serialize()
{

/* removed to stop hackers */

}

void Square::highlight(bool should_highlight)
{
    m_highlight = should_highlight;
emit this->highlight_changed(should_highlight);
}
